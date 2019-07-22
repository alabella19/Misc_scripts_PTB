##This script will compute the IHH values for ancestral and derrived 
.libPaths("~/R/rlib-3.4.3")
#load R modules
library(rehh)


args = commandArgs(trailingOnly=TRUE)
thap_file = args[1]
inp_file = args[2]

hap<-data2haplohh(hap_file=thap_file,map_file=inp_file, haplotype.in.columns = TRUE, recode.allele=TRUE, chr.name=21)
res.scan<-scan_hh(hap ,threads = 8)
out_file<-paste(thap_file, ".res.scan.txt",sep="")
write.csv(file = out_file, res.scan)
