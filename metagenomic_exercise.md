# Metagenomic analysis 


## Learning Objectives

1.  Reporting bioinformatics projects using Markdown
2.  Analyzing shotgun metagenme data
3.  Data munging with R
4.  Kraken, BWA analysis

## Introduction
A recent paper looked in depth at the [environmental metagenome of the NYC subway.](  
http://www.sciencedirect.com/science/article/pii/S2405471215000022)  

This caused [a lot of publicity.](
http://www.nytimes.com/2015/02/07/nyregion/bubonic-plague-in-the-subway-system-dont-worry-about-it.html)

Then follow-up [discussion](http://microbe.net/2015/02/17/the-long-road-from-data-to-wisdom-and-from-dna-to-pathogen/) of wrong calls about anthrax and plague being present in the subway were made.  
  
Species composition was determined using the [megablast-LCA](http://www.sciencedirect.com/science/article/pii/S2405471215000022) and [metaphlan](https://paperpile.com/app/p/39693e3b-ccd1-0958-9347-be9383c22a58) tools.  An alternative approach 
is to use the rapid k-mer based Kraken software. In this exercise we will compare the results from Kraken 
to the published data and also look at the data from a view other angles.

## Write up results using markdown
For the assignment, I would like students to complete at least 3 of the 4 sections below.  Think of the instructions in each section as guidelines for an exploratory data analysis.  Feel free to try different approaches/ parameters and explore results that you think are interesting in more depth.

The *most important* element of this assignment is not the results themselves but the write-up.  Integrate your code with commentary that will help users understand your choices but dont put so much extra text in that it becomes a chore to read.  For each section that you complete include a succinct intros at the beginning and discssion of results at the end.  You can create a markdown (.md) file from an Rmd on the command line like this.

    Rscript -e "library(knitr); knit('my.Rmd')"

There are several free markdown editors avaialble if you would like to further edit your files.

* [Stackedit](https://stackedit.io) (Chrome browser)
* [MacDown](https://macdown.uranusjr.com) (Mac)
* [Remarkable](https://remarkableapp.github.io) (Windows/ Linux)

The easiest way to add images is to place them in your results directory and use relative paths, e.g

![](./Dna.png)


## Data
I have made sequence data for 4 (out of the more than 1400) samples from the NYC project available on Dropbox.  These data were originally downloaded from NCBI and I have extracted the fastq data.  The data are in zipped folders containing forward and reverse Illumina reads.  Choose one of the four samples to work on: 

* P00134
* P00497
* P00073
* P00070

Each project is in a folder in the directory  /home/Shared/IBS574/TDR-metagenome-practical

Within each folder are two zipped fastq files - the forward and reverse reads.

(A side note: the P00134 project actually had two runs, but for simplicity I am not including here the run 
SRR1748707 that produced less data).  

## Part I: Access the data and examine sequence quality
ssh into the blnx1 server and then clone the repo 

     git clone https://github.com/IBS574/metagenome_assignment.git
     cd metagenome_assignment

You should copy the zipped fastq files you are working on to your local directory.

Make an assessment of the quality of the FASTQ data. If you are familiar with the [FASTQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) tool, this can be used.  To find out about how to run this program, use:

	fastqc -h

You will have to create a directory in your analysis folder for each file and then specify this directory using the ```-o``` option in ```fastqc```

You will need to ```unzip``` your fastqc analysis results to get at the folder with images and stats etc.

Another way is to use the ```SR-qualplot.R``` file in your github directory.  (Note - this may require that you install the Bioconductor *ShortRead* package. 

	library(BiocInstaller)
	biocLite("ShortRead")

You can run this analysis using this command:

	Rscript SR-qualplot.R /<insert path to directory with FASTQ files>/

You should get an image for each FASTQ file.  

How can you get the number and length of the reads in the FASTQ files? (*hint: think UNIX*). What other information would be useful to put in a report?

## Part II: Kraken analysis
[Kraken](https://paperpile.com/app/p/b130e880-bddc-0891-8bca-4e9e4c789af2) is a software that classifies each read in a shotgun metagenome sample.  

More nformation on using Kraken on its [project webpage.](http://ccb.jhu.edu/software/kraken/)

Run this command to understand options for running this program.  

    kraken -h 

Run kraken using the minikraken database.  <FILE1> and <FILE2> are the paths to the zipped fastq files for your project

     kraken --db /home/Shared/IBS574/TDR-metagenome-practical/minikraken_20141208 --fastq-input --gzip-compressed --paired <FILE1>.fastq.gz <FILE2>.fastq.gz --classified-out ./krak_classified_reads > ./kraken_out
     kraken-report --db /home/Shared/IBS574/TDR-metagenome-practical/minikraken_20141208 kraken_out > kraken_report

Take a look through the three output files you have created (krak\_classified\_reads, kraken.out, kraken\_report) 
and try to understand what they are.  The projects may have hits against the biodefense pathogens *Bacillus anthracis* 
and *Yersinia pestis*.  Write a UNIX pipeline or a short ad hoc python script (or combination) that identifies the 
reads that map to these pathogens.  Save them in a FASTA and run a BLAST search against the NCBI database.  Do these 
reads have their best match against the biodefense pathogens, or could they come from close relatives?

_(Hint: it will be helpful to find the NCBI Taxonomy ID associated with each species. This can be found in the 
kraken\_report file. The fourth column is the taxonomic rank ('S' is for species) and the fiftth column is the NCBI 
Tax ID)_

You can perform a BLAST search locally against the NCBI non-redundant nucleotide database using the following command (or use the NCBI web pages if you prefer)

     blastn -db /home/Shared/IBS574/BlastDB/nt  -query <YOUR QUERY FASTAFILE> -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids"
     
Here, I have customized the output format to include the *staxids* field, which is the taxonmy ID of the subject match.  See the blastn -help option for details.  

There are several ways to tackle the problem of pulling out a specific subset of reads reads from the FASTQ file.  See the script _knight_script.R_ you can use/adapt, which written by GMB student, Anna Knight, as a solution to this problem in class. (Note: this requires installling the BioConductor Biostrings package, if not already installed).

Now you can blast the files.  Here we are using a copy of the NCBI nucleotide database and the query files are the ones we just pulled out of the FASTQ files.  Here a re a set of unix commands to BLASt and parse the output.  Make sure you understand how this works and explain in your write-up.

     blastn -db /home/Shared/IBS574/BlastDB/nt  -query seqforpestis.fasta  -outfmt "6 stitle qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids" >Blastouputoestis2
     
     awk '{print $1,$2}' Blastouputoestis2 | sort -u
     
     blastn -db /home/Shared/IBS574/BlastDB/nt  -query seqforanthrax.fasta  -outfmt "6 stitle qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids" >Blastoutputanthrax2
     
     awk '{print $1,$2}' Blastoutputanthrax2 | sort -u

## Part III: Munging the data from supplemental data excel spreadsheet using R
The word *'munge'* appears to have have come into common usage in 
[Scotland and Northern England in the 1940s-1950s](http://english.stackexchange.com/questions/207936/what-is-the-etymology-of-munge), 
as a verb, meaning to munch up into a masticated mess.

To modern data science usage, to *munge* is to find ad hoc solutions to messy formatting problems.

In this case, the supplemental data for the paper contains a valuable excel spreadsheet that summarizes metadata 
about the 1400+ samples and the results of the species assignment using the Metaphlan program.  This is an unwieldy data set to work with in 
Excel. It is better and more reproducible to bring it in to R and work with it there.  Extracting useful 
information form Excel files is a common time-consuming task in bioinformatics.  

In RStudio you can open the Excel file (which I have converted to .csv (comma-separated) with this line:

     temp.csv <- read.csv("/home/Shared/IBS574/TDR-metagenome-practical/DataTable5-metaphlan-metadata_v19.csv",stringsAsFactors = FALSE, header = TRUE)
     
You will see that the spreadsheet contains, in effect, two tables.  The first 29 columns describe the metadata 
for each sample (location, GPS, temperature etc).  The rest of the columns describe the percent abundance of 
taxonomic groups identified by Metaphlan.  The first thought is that the abundances for each row should add up to 
100% but instead they add up to about 800% (how can you show this?).  You realize that this is becasue the 
percentage abundance for each taxonomic rank is shown separately and there are eight taxonomic ranks represented 
(see below).  To compare across samples, we only want to focus on one rank.  Let's pick a genus-level 
classification.  A typical record looks like this:

>"k__Bacteria.p__Proteobacteria.c__Gammaproteobacteria.o__Pseudomonadales.f__Pseudomonadaceae.g__Pseudomonas.s__Pseudomonas_sp_TJI_51.t__GCF_000190455"

So, 'k__' means the kingdom rank, 'c__' = class , and so on.  To get the genus level information, you need to 
somehow pick out the columns that contain 'g__' but not 's__'.  

There are numerous ways to do this, R, UNIX, python etc.  Here is a way that illustrates a useful property of grep 
in R and also R set functions.

If you grep for the 'g__' pattern in the columns names, you get a vector of numbers.  These are the columns that 
contain the pattern.

     grep("g__",colnames(temp.csv))
     [1]   35   36   37   38   42   43   44   46   47   48   49   52   53   55   56   57   58   64   65   66   71   72   73
     [24]   74   75   77   78   79   80   82   83   84   85   87   88   89   90   91   92   93   94   95   96   97   98   99
     etc etc
     
You can then use the R 'setdiff' set function to list the columns that contain 'g__' but not 's__'.

     genera <- setdiff(grep("g__",colnames(temp.csv)),grep("s__",colnames(temp.csv)))
     
You can check by looking at the columns of the table corresponding to the numbers using R's subsetting.  You can 
also check that the sums of the proportions add up to 100% (which they do in almost all cases - for this analysis 
we'll not worry about these unusual rows).  Make sure you understand the commands below.

     colnames(temp.csv)[genera]
     apply(temp.csv[genera],1,sum)

Given the above, try and answer the following questions.

1.  Are any genera called present in the Kraken analysis that were not in the metaphlan (or vice versa)? _[QUITE HARD - you will need to google about pattern matching in R]_
2. What were the 20 most common bacterial genus discovered in the study (in terms of the number of samples where the genus was identified as > 0% of the microbiome)?
3.  What was the most common genus found in Brooklyn?
4.  Make a scatterplot of the proportion of the phyla Firmicutes and Bacteroides in each sample.

I encourage you to think of other interesting questions in addition to, or instead of, the ones above and include them in your analysis.

## Part IV: Align reads against commonly encountered bacterial genomes and qualitative analysis using IGV  
From the previous analysis you will see that *Pseudomonas stutzeri* and *Bacillus cereus* are commonly found 
on the NYC subway surfaces.  Here we will go back and map the metogenome data directly on to refernce genomes 
of these species using the BWA software tool in order to understand the pattern of sequecne reads mapping against 
the individual strains.

Get the fasta files of the chromosmes directly from NCBI using curl.

     curl "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=146280397&rettype=fasta&retmode=text" > Pstutz.fasta
     curl "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=30018278&rettype=fasta&retmode=text" > Bcereus.fasta
     
Choose one of these species (or both if you like).  Follow the path below to run the BWA mem alignment program, 
changing names and paths appropriately.  You may want to move the analysis to a new separate directory.

First create an index for the reference fasta file.  This will create the output below.

     bwa index Bcereus.fasta 
     [bwa_index] Pack FASTA... 0.04 sec
     [bwa_index] Construct BWT for the packed sequence...
     [bwa_index] 1.43 seconds elapse.
     [bwa_index] Update BWT... 0.03 sec
     [bwa_index] Pack forward-only FASTA... 0.03 sec
     [bwa_index] Construct SA from BWT and Occ... 0.60 sec
     [main] Version: 0.7.5a-r405
     [main] CMD: bwa index Bcereus.fasta
     [main] Real time: 2.140 sec; CPU: 2.130 sec

This creates some new binary files in your directory.  Just like BLAST indexes , you dont need to worry about them.  
Then run the metagenome fastq files against the index (here my fastq.gz files are in the directory belew so I use 
the '../' prefix - you may have set up your directories differently).

     bwa mem -t 1 Bcereus.fasta ../SRR1748618_1.fastq.gz ../SRR1748618_2.fastq.gz > Bcereus.sam & 
     
The -t option means that only a single processor is used to save resources.  The ampersand (&) means that the process 
runs in the background.  BWA will run for a while spitting out a lot of verbiage.  The results are being saved in a 
SAM format file.  If you are not familiar with SAM and BAM format files, this is a good place to start.  

http://en.wikipedia.org/wiki/SAMtools

The output SAM format file is text. Take a look at it and think of a way to count the number of reads mapped agianst 
the B. cereus genome.  __How does it compare with the results from Kraken and Metaphlan?__

Using samtools the SAM files can be converted to the binary BAM format, which is more compact and customarily used 
for downstream analysis.

     samtools view -bS -o Bcereus.bam Bcereus.sam
     
Then the BAM file is sorted (reads arranged in order of where they align to the referrence) for further downstream 
efficency and indexed.

     samtools sort Bcereus.bam Bcereus_sorted
     samtools index Bcereus_sorted.bam
     
The easist next step is to copy the .bam file, its index (.bai) and the Bcereus fasta file back to a folder on your 
home computer.  Don't sync through git - the file is too large. If you are on a Mac or Linux machine, go to folder in 
your home computer where you want to save the file and use the scp command to retrieve the file.  Below is the command 
I used (with the path to the directories I created).  Windows users see [Suggested SFTP tools](http://ibs574.github.io/docs/setup/#windows-environment). You will need your server pasword.  Substitute <PATH-TO> with the specific path on the server

     scp myid@blnx1.emory.edu:<PATH-TO>/Bcereus_sorted.bam ./
     scp myid@blnx1.emory.edu:<PATH-TO>/Bcereus_sorted.bam.bai ./
     scp myid@blnx1.emory.edu:<PATH-TO>/Bcereus.fasta ./
     
Next is to visualize the aligned reads using the Broad IGV.  The most current version is 2.3.40.  The free software 
can be downloaded from: 

http://www.broadinstitute.org/igv/home

You will need to register your email in order to download.  Open the IGV and then open the 'Genomes' tab.  Click 
the 'Create .genomes file'. Upload the FASTA file for the genome.  Then in the 'File' tab, go to 'Load from file' 
and upload the BAM file.   

Adjust the scale on the top right hand side to view the sequecne reads. Right click on a read and choose the 'View 
as pairs' option. Make sure you under what the arrows and the colors on the pairs mean.

Annotation data, as GFF3 format files can be downleaded at these URLs:

- [*B. cereus* GFF3](https://www.dropbox.com/s/g10i7gtrloe91k9/Bcereus.gff?dl=0)
- [*P. stutzeri* GFF3](https://www.dropbox.com/s/k5qkdkuunc1hjfe/Pstutz.gff?dl=0)

Download to your computer and then load the appropriate GFF3 into the IGV.  You will need to right-click on the 
track and select the Expanded view.

Examine the alignments and make some screen-grabs for your report.  Questions to think about include:
- Is the distribtion of aligned reads even across the genome?
- Are there regions with unusually high or low coverage?  
- Are there any 'broken' mate-pairs and why might this be happening.  
- In general, are there a large number of SNPs between the individual reads and the genome?  
- Is there any evidence that the metagenome reads derive from more than one genetically distinct organism?
