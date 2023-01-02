rm(list = ls())


#Will check to see if the required packages are installed and if not, will install them
packages <- c("data.table", "dplyr", "tidyr", "ggplot2", "patchwork", "plotly", "stringr", "tidyverse", "tibble")
check.package <- function(package){
  if(!(package %in% installed.packages())) install.packages(package)
}
sapply(packages, check.package)
sapply(packages, require, character.only = T)

wd <- paste(getwd(),"/", sep = "")
#wd <- setwd('/Users/andrewd/Desktop/TimeLapse_Focianalysis/test/')
tInitial = 15 #time at which acquisition was started
tsFactor = 10 #The timescale factor used to annotate the plots with the correct timepoints; This repsents how often you are aquiring a new stack (i.e. every 20s)
ntimes = 21

#=======================================================
iCellCount <- length(list.dirs(wd, full.names = TRUE, recursive = TRUE))-1
ROIValues <- read.csv('ROI_values.csv', header =  TRUE)
ROIValues <- ROIValues[2:4]
Headers <- c("Cell_FRAME", "ROI", "LABEL", "AREA", "MEAN")
labelsplit <- as.data.frame(str_split_fixed(ROIValues$Label, ":", 2))
labelsplit$V1 <- gsub(".tif_C.","",as.character(labelsplit$V1)) 
MergedDF <- cbind(labelsplit, ROIValues)
colnames(MergedDF) <- Headers

Headers <- c("Label",  "NucleusArea_Ch2", "NucleusMean_Ch2", "IntersectionArea_Ch2", "IntersectionMean_Ch2","NucleusArea_Ch1", "NucleusMean_Ch1","IntersectionArea_Ch1", "IntersectionMean_Ch1")
SortedDF <- data.frame(matrix(ncol = 9))
colnames(SortedDF) <- Headers
FreqTable <- as.data.frame(table(MergedDF$Cell_FRAME))
FreqTable <- subset(FreqTable, FreqTable$Freq == 4)
MergedDF <- MergedDF[MergedDF$Cell_FRAME %in% FreqTable$Var1,]


SortedDF <- as.data.frame(matrix(MergedDF$MEAN[MergedDF$MEAN!=""], ncol=4, byrow=TRUE))
names(SortedDF) <- c("NucleusMean_Ch2", "IntersectionMean_Ch2", "NucleusMean_Ch1", "IntersectionMean_Ch1")
SortedDF
CellIDs <- data.frame(unique(MergedDF$Cell_FRAME))
colnames(CellIDs) <- "Cell_ID"
SortedDF <- cbind(CellIDs, SortedDF)
SortedDF$NFratio_Ch2 <- SortedDF$IntersectionMean_Ch2/SortedDF$NucleusMean_Ch2
SortedDF$NFratio_Ch1 <- SortedDF$IntersectionMean_Ch1/SortedDF$NucleusMean_Ch1
labelsplit <- as.data.frame(str_split_fixed(SortedDF$Cell_ID, "_", 2))
colnames(labelsplit) <- c("CELL", "FRAME")
SortedDF <- cbind(labelsplit, SortedDF[2:length(SortedDF)])
FreqTable <- as.data.frame(table(SortedDF$CELL))
FreqTable <- subset(FreqTable, FreqTable$Freq == ntimes)
SortedDF <- SortedDF[SortedDF$CELL %in% FreqTable$Var1,]

T0int <- subset(SortedDF, FRAME == "00")
T0Means_Ch2<- as.list(T0int$NFratio_Ch2)
T0Means_Ch2<-rep(T0Means_Ch2,each=ntimes)
T0Means_Ch1<- as.list(T0int$NFratio_Ch1)
T0Means_Ch1<-rep(T0Means_Ch1,each=ntimes)
SortedDF$T0Means_Ch2 <- as.numeric(T0Means_Ch2)
SortedDF$T0Means_Ch1 <- as.numeric(T0Means_Ch1)
SortedDF$ScaledINT_Ch2 <- (SortedDF$NFratio_Ch2/SortedDF$T0Means_Ch2)-1
SortedDF$ScaledINT_Ch1 <- (SortedDF$NFratio_Ch1/SortedDF$T0Means_Ch1)-1
SortedDF$TIME <- tInitial + (as.numeric(SortedDF$FRAME) * tsFactor)

SortedDF <- as.data.table(SortedDF, TRUE)
SortedDF[ ,Ch1_1stSlope := (ScaledINT_Ch1 - shift(ScaledINT_Ch1))/(TIME - shift(TIME))] 
SortedDF[ ,Ch1_2ndSlope := (Ch1_1stSlope - shift(Ch1_1stSlope))/(TIME - shift(TIME))] 
SortedDF[ ,Ch2_1stSlope := (ScaledINT_Ch2 - shift(ScaledINT_Ch2))/(TIME - shift(TIME))]
SortedDF[ ,Ch2_2ndSlope := (Ch2_1stSlope - shift(Ch2_1stSlope))/(TIME - shift(TIME))]

SortedDF$Ch1_1stSlope[which(SortedDF$TIME == "15")] <- NA
SortedDF$Ch1_2ndSlope[which(SortedDF$TIME == "15" | SortedDF$TIME == "25")] <- NA
SortedDF$Ch2_1stSlope[which(SortedDF$TIME == "15")] <- NA
SortedDF$Ch2_2ndSlope[which(SortedDF$TIME == "15" | SortedDF$TIME == "25")] <- NA
############################################################################################################################################
#SortedDF <- subset(SortedDF, (SortedDF$CELL != 109) & (SortedDF$CELL != 193)) #If you wish to remove a cell from the plots, identify the cell in this line
############################################################################################################################################


fCells <- length(unique(SortedDF$CELL))
RetainedCells <- as.character(round((fCells/iCellCount)*100, 2))
CellPercent <- paste(RetainedCells, "%")


Ch1Int<- ggplot(SortedDF, aes(x=TIME, y=ScaledINT_Ch1, group = CELL)) +
  geom_point(color="lightgrey") +
  geom_smooth(color="Chartreuse3", se = FALSE) +
  ggtitle("Foci Intensity of Channel 1") +
  ylab("Normalized Mean Intensity") +
  xlab("Time (s)") +
  #ylim(-0.5, 0.5) +
  xlim(0, 215) +
  geom_vline(xintercept=0, linetype="dashed", color = "Darkgrey") +
  geom_vline(xintercept=15, linetype="solid", color = "Darkgrey") +
  # annotate("text", x=193, y=0.25, label= "# of cells: ") +
  # annotate("text", x=200, y=0.25, label=  fCells) +
  # annotate("text", x=184, y=0.24, label= "% of cells retained: ") +
  # annotate("text", x=200, y=0.24, label=  CellPercent) +
  annotate("text", x=193, y=-0.43, label= "# of cells: ") +
  annotate("text", x=200, y=-0.43, label=  fCells) +
  annotate("text", x=183, y=-0.455, label= "% of cells retained: ") +
  annotate("text", x=200, y=-0.455, label=  CellPercent) +
  annotate("text", x=17, y=0.45, label=  "Acquisition", angle = 90, color= "Darkgrey") +
  annotate("text", x=2, y=0.45, label=  "Induction", angle = 90, color= "Darkgrey") +
  theme(legend.position="none", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) 

ggplotly(Ch1Int)
png(file="FociInt_Ch1.png",width=1500, height=900, res=100)
plot(Ch1Int)
dev.off()


Ch2Int<- ggplot(SortedDF, aes(x=TIME, y=ScaledINT_Ch2, group=CELL)) +
  geom_point(color="lightgrey") +
  geom_smooth(color="darkviolet", se=FALSE) +
  ggtitle("Foci Intensity of Channel 2") +
  ylab("Normalized Mean Intensity") +
  xlab("Time (s)") +
  #ylim(-0.5, 0.5) +
  xlim(0, 215) +
  geom_vline(xintercept=0, linetype="dashed", color = "Darkgrey") +
  geom_vline(xintercept=15, linetype="solid", color = "Darkgrey") +
  # annotate("text", x=193, y=0.25, label= "# of cells: ") +
  # annotate("text", x=200, y=0.25, label=  fCells) +
  # annotate("text", x=184, y=0.24, label= "% of cells retained: ") +
  # annotate("text", x=200, y=0.24, label=  CellPercent) +
  annotate("text", x=193, y=-0.43, label= "# of cells: ") +
  annotate("text", x=200, y=-0.43, label=  fCells) +
  annotate("text", x=183, y=-0.455, label= "% of cells retained: ") +
  annotate("text", x=200, y=-0.455, label=  CellPercent) +
  annotate("text", x=17, y=0.45, label=  "Acquisition", angle = 90, color= "Darkgrey") +
  annotate("text", x=2, y=0.45, label=  "Induction", angle = 90, color= "Darkgrey") +
  theme(legend.position="none", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) 

ggplotly(Ch2Int)
png(file="FociInt_Ch2.png",width=1500, height=900, res=100)
plot(Ch2Int)
dev.off()

#===============================================================================================================================
# Average across all cells

averageDF_Ch1 <- aggregate(SortedDF$ScaledINT_Ch1,list(SortedDF$FRAME),mean)
averageDF_Ch2 <- aggregate(SortedDF$ScaledINT_Ch2,list(SortedDF$FRAME),mean)

averageDF <- data.frame()
averageDF <-  data.frame(unique(SortedDF$TIME))
averageDF <- cbind(averageDF, averageDF_Ch1$x, averageDF_Ch2$x)
colnames(averageDF) <- c('Time', 'AverageINT_Ch1', 'AverageINT_Ch2')


averageDF <- as.data.table(averageDF, TRUE)
averageDF[ ,Ch1_firstSlope := (AverageINT_Ch1 - shift(AverageINT_Ch1))/(Time - shift(Time))]
averageDF[ ,Ch1_secondSlope := (Ch1_firstSlope - shift(Ch1_firstSlope))/(Time - shift(Time))]
averageDF$Ch1_firstSlope[which(averageDF$Time == "15")] <- NA
averageDF$Ch1_secondSlope[which(averageDF$TIME == "15" | averageDF$TIME == "25")] <- NA

averageDF[ ,Ch2_firstSlope := (AverageINT_Ch2 - shift(AverageINT_Ch2))/(Time - shift(Time))]
averageDF[ ,Ch2_secondSlope := (Ch2_firstSlope - shift(Ch2_firstSlope))/(Time - shift(Time))]
averageDF$Ch2_firstSlope[which(averageDF$Time == "15")] <- NA
averageDF$Ch2_secondSlope[which(averageDF$TIME == "15" | averageDF$TIME == "25")] <- NA




ggplot(averageDF, aes(x=Time, y=AverageINT_Ch1)) +
  geom_point(color="lightgrey") +
  geom_smooth(color="Chartreuse3", se=FALSE) +
  ggtitle("Foci Intensity of Channel 1") +
  ylab("Mean Intensity") +
  xlab("Time (s)") +
  theme(legend.position="none", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) +


ggplot(averageDF, aes(x=Time, y=AverageINT_Ch2)) +
  geom_point(color="lightgrey") +
  geom_smooth(color="DarkViolet", se=FALSE) +
  ggtitle("Foci Intensity of Channel 2") +
  ylab("Mean Intensity") +
  xlab("Time (s)") +
  theme(legend.position="none", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) 



#Generates and outputs a plot superimposing average intensities of Channel 1 and Channel 2
AverageInt <- ggplot(averageDF, aes(x=Time, y=AverageINT_Ch1, color="AverageINT_Ch1")) +
  geom_smooth(se=FALSE) +
  ggtitle("Average Normalized Foci Intensity") +
  ylab("Normlized Mean Intensity") +
  xlab("Time (s)") +
  ylim(-0.05, 0.05) +
  xlim(0, 215) +
  geom_vline(xintercept=0, linetype="dashed", color = "Darkgrey") +
  geom_vline(xintercept=15, linetype="solid", color = "Darkgrey") +
  theme( axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) +
  geom_smooth(mapping =aes(x=Time, y=AverageINT_Ch2, color = "AverageINT_Ch2"), se=FALSE) +
  # annotate("text", x=193, y=0.25, label= "# of cells: ") +
  # annotate("text", x=200, y=0.25, label=  fCells) +
  # annotate("text", x=184, y=0.24, label= "% of cells retained: ") +
  # annotate("text", x=200, y=0.24, label=  CellPercent) +
  annotate("text", x=190, y=-0.043, label= "# of cells: ") +
  annotate("text", x=200, y=-0.043, label=  fCells) +
  annotate("text", x=180, y=-0.0455, label= "% of cells retained: ") +
  annotate("text", x=200, y=-0.0455, label=  CellPercent) +
  annotate("text", x=17, y=0.045, label=  "Acquisition", angle = 90, color= "Darkgrey") +
  annotate("text", x=2, y=0.045, label=  "Induction", angle = 90, color= "Darkgrey") +
  scale_colour_manual(name = "", 
                      values = c("AverageINT_Ch1" = "Chartreuse3", 
                                 "AverageINT_Ch2" = "DarkViolet"))
AverageInt


png(file="MaxIntensityPlot.png",width=1300, height=900, res=100)
plot(AverageInt)
dev.off()


#Generates and outputs a plot superimposing the slopes of Channel 1 and Channel 2
firstSlope <- ggplot(averageDF, aes(x=Time, y=Ch1_firstSlope, color="Ch1_slope")) +
  geom_smooth(se=FALSE) +
  ggtitle("Average Normalized Foci Intensity") +
  ylab("Normlized Mean Intensity") +
  xlab("Time (s)") +
  #ylim(-0.001, 0.001) +
  xlim(0, 215) +
  geom_vline(xintercept=0, linetype="dashed", color = "Darkgrey") +
  geom_vline(xintercept=15, linetype="solid", color = "Darkgrey") +
  theme( axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) +
  geom_smooth(mapping =aes(x=Time, y=Ch2_firstSlope, color = "Ch2_slope"), se=FALSE) +
  scale_colour_manual(name = "", 
                      values = c("Ch1_slope" = "Chartreuse3", 
                                 "Ch2_slope" = "DarkViolet"))
firstSlope

png(file="FirstSlope.png",width=1300, height=900, res=100)
plot(firstSlope)
dev.off()


#Generates and outputs a plot superimposing the derivative of slopes of Channel 1 and Channel 2
secondSlope <- ggplot(averageDF, aes(x=Time, y=Ch1_secondSlope, color="Ch1_slope")) +
  geom_smooth(se=FALSE) +
  ggtitle("Average Normalized Foci Intensity") +
  ylab("Normlized Mean Intensity") +
  xlab("Time (s)") +
  #ylim(-0.001, 0.001) +
  xlim(0, 215) +
  geom_vline(xintercept=0, linetype="dashed", color = "Darkgrey") +
  geom_vline(xintercept=15, linetype="solid", color = "Darkgrey") +
  theme( axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) +
  geom_smooth(mapping =aes(x=Time, y=Ch2_secondSlope, color = "Ch2_slope"), se=FALSE) +
  scale_colour_manual(name = "", 
                      values = c("Ch1_slope" = "Chartreuse3", 
                                 "Ch2_slope" = "DarkViolet"))
secondSlope

png(file="SecondSlope.png",width=1300, height=900, res=100)
plot(secondSlope)
dev.off()

write.csv(averageDF, "AvgCell_Intensity.csv")
write.csv(SortedDF, "PerCell_Intensity.csv")



split_data <- split(SortedDF, f = SortedDF$CELL)
splitNames <- names(split_data)


# Make plots for each 
plot_list = list()
for (i in splitNames){
  CellInt <- ggplot(split_data[[i]], aes(x=TIME, y=ScaledINT_Ch1, color="INT_Ch1")) +
    geom_line() +
    geom_smooth(color = "lightgray", se = FALSE, alpha = 0.1) +
    geom_smooth(mapping =aes(x=TIME, y=ScaledINT_Ch2), color = "lightgray", se = FALSE, alpha = 0.1) +
    ggtitle(c("Individual Normalized Foci Intensity for: ", i )) +
    ylab("Normlized Mean Intensity") +
    xlab("Time (s)") +
    ylim(-0.25, 0.25) +
    xlim(0, 215) +
    geom_vline(xintercept=0, linetype="dashed", color = "cornsilk4") +
    geom_vline(xintercept=15, linetype="solid", color = "cornsilk4") +
    theme( axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) +
    geom_line(mapping =aes(x=TIME, y=ScaledINT_Ch2, color = "INT_Ch2")) +
    annotate("text", x=17, y=0.045, label=  "Acquisition", angle = 90, color= "cornsilk4") +
    annotate("text", x=2, y=0.045, label=  "Induction", angle = 90, color= "cornsilk4") +
    scale_colour_manual(name = "",
                        values = c("INT_Ch1" = "Chartreuse3",
                                   "INT_Ch2" = "DarkViolet"))
  
  plot_list[[i]] = CellInt
  
} 

# Save plots to tiff. Makes a separate file for each plot.
for (i in splitNames) {
  plotname <- paste0(i, ".png", sep = "")
  png(file=plotname,width=1300, height=900, res=100)
  plot(plot_list[[i]])
  dev.off()
}

