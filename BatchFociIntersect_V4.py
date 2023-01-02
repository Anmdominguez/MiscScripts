 
import sys
import os
from ij import IJ
from ij import WindowManager
from ij.plugin.frame import RoiManager
from ij import ImageStack, ImagePlus



IntMeasure = """
NTPs = 21
FociDilation = 0.3

//input = getDir(“cwd”);
input = getDirectory("Choose a Directory");

listdir = getFileList(input); 
output = input;
setBatchMode(true);
close("*");
run("Clear Results");
for (i=0; i<listdir.length; i++) { 
	if(endsWith(listdir[i], "/")) {
		inputfolder = input+listdir[i];
		listfiles = getFileList(inputfolder);
			for (j=0; j<NTPs; j++) {
		        if(endsWith(listfiles[j], ".tif")) {
		        		open(inputfolder+listfiles[j]);
						ImageTitle = getTitle();
						//print(ImageTitle);
						rename(ImageTitle);
						run("To ROI Manager");
						nROIs = roiManager("count");
						//print(nROIs);
						
						if(nROIs==1){
							roiManager("Select", 0);
							run("Enlarge...", "enlarge=FociDilation");
							roiManager("Add");
							roiManager("Select", 1);
							roiManager("Rename", "Foci");
							run("Select None");
							
							run("Duplicate...", "title=TargetImage duplicate");
							run("Split Channels");
							selectWindow("C3-TargetImage");
							close();
							
							selectWindow("C2-TargetImage");
							rename(ImageTitle + "_C2");
							run("Duplicate...", "title=C2-Nuc");
							setAutoThreshold("Default dark");


							setOption("BlackBackground", false);
							run("Convert to Mask");
							run("Dilate");
							run("Erode");
							run("Set Measurements...", "area mean display decimal=3");
							run("Analyze Particles...", "size=0.1-5 overlay add");
							
							nROIs = roiManager("count");
							if(nROIs==3){
							
								selectWindow(ImageTitle + "_C2");
								roiManager("Select", 2);
								roiManager("Rename", "Nucleus-C2");
								roiManager("Measure");
								roiManager("Select", 1);
								//roiManager("Measure");
								roiManager("Select", newArray(1,2));
								roiManager("AND");
							
								type = selectionType();
  								if (type==-1){
  									print("Check Output!! No Nuclear/Foci overlap to generate Ch2 Intersection in: " + ImageTitle );
									roiManager("Select", 2);
									roiManager("Delete");
  									
								} else {
									roiManager("Add");
									roiManager("Select", 3);
									roiManager("Rename", "Intersection-C2");
									roiManager("Measure");	
									roiManager("Select", newArray(2,3));
									roiManager("Delete");
								}
							} else {
								print("Ch2 Nuclear ROI not detected in: " + ImageTitle );
	
							}
								
							
							selectWindow("C1-TargetImage");
							rename(ImageTitle + "_C1");
							run("Duplicate...", "title=C1-Nuc");
							setAutoThreshold("Default dark");

							setOption("BlackBackground", false);
							run("Convert to Mask");
							run("Dilate");
							run("Erode");
							run("Set Measurements...", "area mean display decimal=3");
							run("Analyze Particles...", "size=0.1-5 overlay add");
							
							nROIs = roiManager("count");
							if(nROIs==3){
							
								selectWindow(ImageTitle + "_C1");
								roiManager("Select", 2);
								roiManager("Rename", "Nucleus-C1");
								roiManager("Measure");
								roiManager("Select", 1);
								///roiManager("Measure");
								roiManager("Select", newArray(1,2));
								roiManager("AND");
							
								type = selectionType();
  								if (type==-1){
  									print("Check Output!! No Nuclear/Foci overlap to generate Ch1 Intersection in: " + ImageTitle );
  								
								} else {
							    	roiManager("Add");
									roiManager("Select", 3);
									roiManager("Rename", "Intersection-C1");
									roiManager("Measure");
								}
							} else {
								print("Ch1 Nuclear ROI not detected in: " + ImageTitle );
	
							}
							
							close("*");
							roiManager("Select", 0);
							roiManager("Deselect");
							roiManager("Delete");
						
				} else {
					print(ImageTitle + " has " + nROIs + " ROIs; Skipping");				
				}
	        } 
		}
	}
}


for (i=0; i<listdir.length; i++) { 
	if(endsWith(listdir[i], "/")) {
		inputfolder = input+listdir[i];
		listfiles = getFileList(inputfolder);
			for (j=0; j<listfiles.length; j++) {
		        if(endsWith(listfiles[j], ".tif")) {
		        	open(inputfolder+listfiles[j]);						
				}
	        } 
	        run("Concatenate...", "all_open title=Stack open");
		    saveAs("Tiff", inputfolder + "Stack.tif");
		    close();
	}
}



print("====================================================");
print("");
print("Foci Measurements Completed");
print("");
print("Parameters: ");
//print("		Images were thresholded at: " + THmin + " - " + THmax);
print("		Foci Dilation: " + FociDilation);
print("		Number of timepoints: " + NTPs);
print("		Number of cells analyzed: " + listdir.length-3);
print("");
print("Csv and log files can be found in: ");
print(output);
saveAs("Results", output+ "ROI_values.csv");
selectWindow("Log");
saveAs("Text", output+ "Log.txt");
run("Quit");

"""

IJ.runMacro(IntMeasure)
