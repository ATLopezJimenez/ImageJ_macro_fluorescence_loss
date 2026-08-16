//Ana Teresa Lopez Jimenez macro to quantify bacteria fluorescence in an enlarged bacterial mask.
//Used in manuscript "Proximity biotinylation at the host-bacterial interface reveals UFMylation as an antibacterial pathway".
//Version from Dec 2025
//Serge Mostowy lab, London School of Hygiene and Tropical Medicine


//getting information about the image
dir = getDirectory("image")
name = getTitle()
newname=replace(name, ".tif", "")



//identification of channels
run("Set Measurements...", "area mean standard integrated area_fraction stack display redirect=None decimal=3");
run("Z Project...", "projection=[Max Intensity]");
run("Split Channels");

cDAPI=3;
minthreshold = 8500;
maxthreshold = 65535;
newcDAPI="C" + cDAPI;
print("DAPI channel " + newcDAPI);
print("min thresold " + minthreshold);
print("max threshold " + maxthreshold);
selectWindow(newcDAPI + "-MAX_" + newname + ".tif");
run("Duplicate...", " ");


//doing the mask on DAPI channel, identifying objects and enlarging
setAutoThreshold("Default dark");
setThreshold(minthreshold, maxthreshold);

run("Convert to Mask");
saveAs("Tiff", dir + newname +"_mask.tif");
run("Analyze Particles...", "size=20-6000 circularity=0.0-1.00 pixel exclude clear add");

roiManager("Deselect"); 
roiManager("Save", dir + newname + "_ROI set.zip");

for (i=0;i<roiManager("count");i++){
          roiManager("select", i);
          run("Enlarge...", "enlarge=2 pixel");
          roiManager("update");
}
roiManager("Deselect"); 
roiManager("Save", dir + newname + "_ROI set_enlarged.zip");

//selecting the UFL1 and Cherry channel
cUFL1 = "C1"
cCherry = "C2"


print("UFL1 channel " + cUFL1);
print("mCherry channel " + cCherry);

//create the array
array1 = newArray("0");; 
for (i=1;i<roiManager("count");i++){ 
       array1 = Array.concat(array1,i); 
//       Array.print(array1); 
} 

//measurement in UFL1 channel
imageUFL1 = cUFL1 + "-MAX_" + newname + ".tif";
print(imageUFL1);

roiManager("select", array1); 
run("Set Measurements...", "area mean standard integrated area_fraction stack display redirect=[" + imageUFL1 + "] decimal=3");
roiManager("Measure");
saveAs("Results", dir + newname + "_ResultsUFL1.csv");
run("Clear Results");


//measurement in Cherry channel
imageCherry = cCherry + "-MAX_" + newname + ".tif";
print(imageCherry);

roiManager("select", array1); 
run("Set Measurements...", "area mean standard integrated area_fraction stack display redirect=[" + imageCherry + "] decimal=3");
roiManager("Measure");
saveAs("Results", dir + newname + "_ResultsCherry.csv");
run("Clear Results");

//measurement in DAPI channel
imageDAPI = newcDAPI + "-MAX_" + newname + ".tif";
print(imageDAPI);

roiManager("select", array1); 
run("Set Measurements...", "area mean standard integrated area_fraction stack display redirect=[" + imageDAPI + "] decimal=3");
roiManager("Measure");
saveAs("Results", dir + newname + "_ResultsDAPI.csv");
run("Clear Results");

//closing and saving remaining windows
run("Close All");
selectWindow("Results");
   run("Close");
selectWindow("ROI Manager");
   run("Close");
selectWindow("Log");
   saveAs("Text", dir + "Log " + newname + ".txt");
   run("Close");
