options(echo=TRUE)
options(show.error.locations=TRUE)
#options(error = function() { traceback(3); quit()})
options(error = function() { traceback(3)})
library(DESeq2)
library(yaml)
library(ggplot2)
library(ggrepel)

# Returns a matrix of counts suitable for DESeqDataSetFromMatrix.
# This code courtesy of h.mon on biostars.org - its an elegant snippet of
# code that combines the <sample>.counts.txt files from STAR into a table
# of counts for DESeq2's consumption. https://www.biostars.org/p/241602/
CountsMatrix=function()
{
	ff <- list.files( path = "./Alignments", pattern = "*counts.txt$", full.names = TRUE )
	counts.files <- lapply( ff, read.table, skip = 4 )
	counts <- as.data.frame( sapply( counts.files, function(x) x[ , 4 ] ) )
	ff <- gsub( "[.]counts[.]txt", "", ff )
	ff <- gsub( "[.]/Alignments/", "", ff )
	colnames(counts) <- ff
	row.names(counts) <- counts.files[[1]]$V1
	as.matrix(counts)
}

# Read the sample information table and order it to match the column
# order of the count matrix.
# Also, convert all columns into factors.
ReadSampleData=function(sample_data_file)
{
	x=read.delim(sample_data_file)
	x=x[order(x$Sample),]
	row.names(x)=x$Sample
	x$Sample=NULL
	for ( name in names(x) )
	{
		if ( !is.factor( x[[name]] ) )
		{
			x[[name]]=factor(x[[name]])
		}
	}
	x
}

RunAnalysis=function(pdffile="deseq2_plots.pdf")
{
	# Read the experiment configuration. To do that we need to
	# identify directory where this script is located.
	print("Reading experiment configuration.")
	arguments=commandArgs()
	filearg=grep("--file=",arguments)
	scriptname=sub("--file=","",arguments[filearg])
	scriptdir=normalizePath(dirname(scriptname))
	config=read_yaml(file.path(scriptdir,"config.yaml"))
	print("Reading count data.")
	countdata=CountsMatrix()
	print("Reading sample information.")
	sampledata=ReadSampleData("sampledata.txt")
	# Rename the columns of the countdata matrix (which are named with the 
	# SRRNumber for each sample) with the actual sample name.
	n=sampledata$SRRNumber
	v=rownames(sampledata)
	colnames(countdata)[n]=v
	print("Creating DESeq data set.")
	dds=DESeqDataSetFromMatrix(countdata, sampledata, ~ Treatment + Time )
	# Run the analysison the data set.
	print("Running analysis.")
	dds=DESeq(dds)
	contrast=c(config$factorname,config$numerator,config$denominator)
	# Create a tidy results object for writing as a table.
	res=results(dds,contrast=contrast,tidy=TRUE)
	# Reorder the results by increasing adjusted p.
	res=res[order(res$padj),]
	# Create an untidy results object for plotMA.
	untidy_results=results(dds,contrast=contrast)

	# Save the results and the count data.
	print("Writing results.")
	write.table(countdata,file="project_counts.txt",quote=FALSE,sep="\t",row.names=TRUE,col.names=TRUE)
	write.table(format(res,digits=4),file="project_results.txt",quote=FALSE,sep="\t",row.names=FALSE,col.names=TRUE)

	# Create PCA and MA plots.
	print("Generating figures.")
	if ( !is.null(pdffile) )
	{
		pdf(pdffile)
	}
	ma_title=paste("MA Plot:",config$numerator,"vs",config$denominator)
	plotMA(untidy_results,alpha=0.05,main=ma_title)
	plot_object=plotPCA(rlog(dds),intgroup=c(config$factorname))
	print(plot_object+geom_text_repel(aes(label=name),nudge_x=2)+ggtitle("Principal Components Analysis"))
	if ( !is.null(pdffile) )
	{
		dev.off()
	}
	print("Statistical analysis done.")
}

RunAnalysis()
