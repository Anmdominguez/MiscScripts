
import sys
import os
from ij import IJ
from ij import WindowManager
from ij.plugin.frame import RoiManager
from ij import ImageStack, ImagePlus

BioformatsConvert = """
input = getDirectory("Choose a Directory"); 
list = getFileList(input); 
output = input + "Max Projections" + File.separator;
setBatchMode(true);
if (File.exists(output)) 
   exit("Destination directory already exists; remove it and then run this macro again"); 
File.makeDirectory(output); 
for (i=0; i<list.length; i++) { 
        if(endsWith(list[i], ".ims")) {
        		run("Bio-Formats Importer", "open=["+ input + list[i] +"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
                run("Z Project...", "projection=[Max Intensity]"); 
                saveAs("tiff", output + getTitle); 
                close();
                close(); 
        } 
}
"""


IJ.runMacro(BioformatsConvert)