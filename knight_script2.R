setwd("~/metagenome_assignment/")
library("Biostrings")
library("ShortRead")

#my krak_classified_reads were in fastq format
reads<-readDNAStringSet("krak_classified_reads", format ="fasta")
report<-read.table("kraken_report", sep="\t", as.is=T)
a<-read.table("kraken_out",sep = "\t", as.is=T)
a1<-a[,2:3]
anthrax<-subset(a1, a1$V3==1392)
pestis<-subset(a1, a1$V3==632)

anthrax2<-as.character(anthrax$V2)
pestis2<-as.character(pestis$V2)

writeXStringSet(reads[names(reads) %in% pestis2],"Ypestis.fasta")
writeXStringSet(reads[names(reads) %in% anthrax2],"Banthracis.fasta")

# find_matches <- function(hlist,reads){
#   res <- vector()
#   for (i in hlist){
#     temp <- paste(i," ",sep = "")
#     res1 <-which(grepl(temp,names(reads)))
#     print(res1)
#     res <- append(res,res1)
#   }
#   return(res)
# }
# 
# 
# if (length(pestis2) >0) {
#   results <- find_matches(pestis2,reads)
#   writeFasta(reads[results],"Ypestis.fasta")
# }
# if (length(anthrax2) >0) {
#   results <- find_matches(anthrax2,reads)
#   writeFasta(reads[results],"Banthracis.fasta",format=fasta)
# }