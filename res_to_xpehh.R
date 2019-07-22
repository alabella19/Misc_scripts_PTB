##This script will compute the IHH values for ancestral and derrived 
.libPaths("~/R/rlib-3.4.3")
#load R modules
library(rehh)


args = commandArgs(trailingOnly=TRUE)
res_file = args[1]
res_file2 = args[2]

res_in1<-read.table(res_file,row.names=1,sep="\t",header=TRUE)
res_in2<-read.table(res_file2,row.names=1,sep="\t",header=TRUE)

#get overlapping data
res_in1_sub<-res_in1[match(res_in1$POSITION, res_in2$POSITION, nomatch=0),]
res_in2_sub<-res_in2[match(res_in2$POSITION, res_in1$POSITION, nomatch=0),]
#get iHS value

xpehh_results<-ies2xpehh(res_in1_sub, res_in2_sub)

pop1<-unlist(strsplit(res_file,"[.]"))[1]
pop2<-unlist(strsplit(res_file2,"[.]"))[1]

info<-unlist(strsplit(res_file,"[.]"))[2:5]
info<-paste(info[1],info[2],info[3],info[4], sep=".")

out_file<-paste(pop1,pop2,info,"xpehh.txt",sep=".")




write.table(file=out_file, xpehh_results, sep='\t', quote=FALSE, row.names=FALSE)
