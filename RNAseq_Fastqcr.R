library(fastqcr);
library(Seurat);
library(dplyr);

# this will run the Fastqc 
qc.dir <- setwd("/Volumes/AuxDrive/RNAseq");  #set the wd direcoty of the fastq files 
qc.dir; #will print the directory to confirm the correct direct was set
list.files(qc.dir) #Lists the files that are in the selected directory (should be Fastq folder and output folder)
fastqc(fq.dir = "/Volumes/AuxDrive/RNAseq/fastq",  #designate the folder containing the fastq files
      qc.dir = "/Volumes/AuxDrive/RNAseq/output",  #designate the output folder for the Fastqc results
      threads = 4)                                 #designates the number of threads used for FASTQCR                     
                    
qc <- qc_aggregate(qc.dir)  #aggregates all the fastqc results and provides summary as a CSV
write.csv(qc,"output.csv")

qc_filter <-as.data.frame(qc)
qc_count <- subset(qc_filter, subset = qc_filter$module == "Per base sequence quality")
qc_fail <- subset (qc_count, subset = qc_count$status == "FAIL")

print("The following samples do not pass basic QC:")
qc_fail$sample

