
import sys
import os
from ij import IJ
from ij import WindowManager
from ij.plugin.frame import RoiManager
from ij import ImageStack, ImagePlus


ROIExtract = """
setBatchMode(true);
output = getDirectory("Choose an output Directory");;
roiManager("Deselect");
roiManager("Sort");
n = roiManager("count");
run("From ROI Manager");
rename("TargetImage");
run("Set Measurements...", "area mean min fit shape display redirect=TargetImage decimal=3");
selectWindow("TargetImage");
Stack.setChannel(1)
for (i = 0; i < n; i++) {
    roiManager("select", i);
    run("Enlarge...", "enlarge=1.50");
    roiManager("update")//Replaces the selected ROI on the list with the current selection.
    roiManager("select", i);
    spotID = RoiManager.getName(i);
    run("Duplicate...", i);
    saveAs("TIFF", output+spotID);
    close();

}
close("*");
print("====================================================");
print("");
print("Foci Extractions Completed")
print(n + " ROIs extracted");
print("");
print("ImageFiles can be found in: ");
print(output);
"""


IJ.runMacro(ROIExtract)
