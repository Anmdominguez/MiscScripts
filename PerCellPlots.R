rm(list = ls())


#Will check to see if the required packages are installed and if not, will install them
packages <- c("data.table", "dplyr", "tidyr", "ggplot2", "patchwork", "plotly", "stringr", "tidyverse", "tibble")
check.package <- function(package){
  if(!(package %in% installed.packages())) install.packages(package)
}
sapply(packages, check.package)
sapply(packages, require, character.only = T)

wd <- paste(getwd(),"/", sep = "")
wd <- setwd('/Users/andrewd/Desktop/TimeLapse_Focianalysis/10.For analysis (aligned)/standard/3782_with_copper_deconvolved./Outputs/')


#=======================================================
ROIValues <- read.csv('PerCell_Intensity.csv', header =  TRUE)
Cell_IDs <- as.list(unique(ROIValues$CELL))

split_data <- split(ROIValues, f = ROIValues$CELL)
list2env(split_data,envir=.GlobalEnv)


for (i in split_data){
  plotname <- as.character(i)
  # CellInt <- ggplot(i, aes(x=i$TIME, y=i$ScaledINT_Ch1, color="AverageINT_Ch1")) +
  #   geom_line() +
  #   ggtitle("Average Normalized Foci Intensity") +
  #   ylab("Normlized Mean Intensity") +
  #   xlab("Time (s)") +
  #   ylim(-0.05, 0.05) +
  #   xlim(0, 215) +
  #   geom_vline(xintercept=0, linetype="dashed", color = "Darkgrey") +
  #   geom_vline(xintercept=15, linetype="solid", color = "Darkgrey") +
  #   theme( axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) +
  #   geom_line(mapping =aes(x=i$TIME, y=i$ScaledINT_Ch2, color = "AverageINT_Ch2")) +
  #   annotate("text", x=17, y=0.045, label=  "Acquisition", angle = 90, color= "Darkgrey") +
  #   annotate("text", x=2, y=0.045, label=  "Induction", angle = 90, color= "Darkgrey") +
  #   scale_colour_manual(name = "",
  #       values = c("AverageINT_Ch1" = "Chartreuse3",
  #                  "AverageINT_Ch2" = "DarkViolet"))
  # 
  # CellInt
  # png(file=plotname,width=1300, height=900, res=100)
  # plot(CellInt)
  # dev.off()
  print(plotname)
} 


CellInt <- ggplot(split_data$`0`, aes(x=TIME, y=ScaledINT_Ch1, color="AverageINT_Ch1")) +
  geom_line() +
  ggtitle("Average Normalized Foci Intensity") +
  ylab("Normlized Mean Intensity") +
  xlab("Time (s)") +
  ylim(-0.05, 0.05) +
  xlim(0, 215) +
  geom_vline(xintercept=0, linetype="dashed", color = "Darkgrey") +
  geom_vline(xintercept=15, linetype="solid", color = "Darkgrey") +
  theme( axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5), plot.title = element_text(hjust = 0.5)) +
  geom_line(mapping =aes(x=TIME, y=ScaledINT_Ch2, color = "AverageINT_Ch2")) +
  annotate("text", x=17, y=0.045, label=  "Acquisition", angle = 90, color= "Darkgrey") +
  annotate("text", x=2, y=0.045, label=  "Induction", angle = 90, color= "Darkgrey") +
  scale_colour_manual(name = "",
      values = c("AverageINT_Ch1" = "Chartreuse3",
                 "AverageINT_Ch2" = "DarkViolet"))

CellInt
