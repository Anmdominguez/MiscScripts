rm(list = ls())

packages <- c( "dplyr", "tidyr", "ggplot2", "patchwork", "plotly", "tibble")
check.package <- function(package){
  if(!(package %in% installed.packages())) install.packages(package)
}
sapply(packages, check.package)
sapply(packages, require, character.only = T)

wd <- paste(getwd(),"/", sep = "")
#wd <- setwd('~/Desktop/Still_analysis/9.2022-11-03 three color imaging Hpr1-mnG Cbp20-mSc for analysis testing/Max_3870_CuSO4/')'




imageMeta <- read.csv("export.csv") 
imageMeta <- imageMeta %>% slice(-1:-3) 
FrameMeta <- as.numeric(imageMeta$FRAME)
FrameMeta <- sprintf("%02d", FrameMeta)
imageMeta$FRAME <- FrameMeta
imageMeta <- imageMeta[order(imageMeta$ID),]


myImages <- list.files(wd, pattern = "\\.tif$")
myImagesDF <- data.frame(myImages)
myImagesDF$fileMatch <- data.frame(paste(imageMeta$LABEL, imageMeta$TRACK_ID, imageMeta$FRAME,  sep="_"))
myImagesDF$Newfilename <- data.frame(paste(imageMeta$TRACK_ID, imageMeta$FRAME,  sep="_"))


file.rename(paste0(wd, myImagesDF$myImages), paste0(wd, myImagesDF$Newfilename$paste.imageMeta.TRACK_ID..imageMeta.FRAME..sep...._.., '.tif'))


trackIDs <- list(unique(imageMeta$TRACK_ID))
for (i in trackIDs) {
  for (j in i) {
    newdir <- j
    dir.create(file.path(newdir), recursive = TRUE)
    filestomove <- list.files(wd, pattern = )
  }
}


                                                     


