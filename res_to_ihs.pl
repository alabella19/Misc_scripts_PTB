##This script will compute the IHH values for ancestral and derrived 
.libPaths("~/R/rlib-3.4.3")
#load R modules
library(rehh)


args = commandArgs(trailingOnly=TRUE)
res_file = args[1]

res_in<-read.table(res_file,row.names=1,sep="\t",header=TRUE)
#get iHS value
ihs_out<-ihh2ihs(res_in)
ihs_only<-ihs_out$iHS

out_file<-paste(res_file, ".iHS.txt",sep="")
write.table(file=out_file, ihs_only, sep='\t', quote=FALSE, row.names=FALSE)
