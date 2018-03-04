library("ShortRead")
# the key difference is that the arg is a FOLDER not one FILE, e.g
# Rscript SR-qualplot-HW.R /home/Shared/IBS574/MiSeq_SOP/
arg <- commandArgs(trailingOnly=TRUE)
#make sure that exactly one arg is entered
if (length(arg) > 1){
  stop('Stop: More than one file entered')
}
if (length(arg)== 0){stop('Stop: n files entered')
}

#find all the fastq files in the directory
fastq_files <- list.files(arg, pattern = "*.fastq")

#this loops over each and creates an output file
for (i in fastq_files) {
  # output pdf file name
  out <- sub("fastq","pdf",i)
  
  # the filepath to the fastaq file i
  fp <- paste(arg,"/",i, sep = "")
  qqF <- qa(fp) #quality assessment
  qqf.pc.qual <- qqF[["perCycle"]]$quality
  pdf(out)
  print(ShortRead:::.plotCycleQuality(qqf.pc.qual))
  dev.off()
  
}
