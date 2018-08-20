//20170825 Michiel Boekhout

//This macro is meant to speed-up isolating single cells from Meiotic spreads.
// From the original image make a duplicates of the region (single cells) you are interested in and specify a destination folder below. Run with either auto-contrasted display, or set display. 
// Sorting the images (manually) in folders depending on their meiotic stage is recommended to facilitate analysis
// To get the filenames of all the images, use the script "PrintFilenames.ijm" for instance.


Imagename = getTitle;
run("Previous Slice [<]");
run("Previous Slice [<]");
//run("Enhance Contrast", "saturated=0.35");
setMinAndMax(150, 3500); //set display as desired
run("Next Slice [>]");
//run("Enhance Contrast", "saturated=0.35");
setMinAndMax(200, 800);
run("Next Slice [>]");
run("Enhance Contrast", "saturated=0.35");
//Stack.setDisplayMode("composite");
Stack.setActiveChannels("110");
saveAs("Tiff", "/ (...) /"+Imagename+""); // replace (...) with target destination
close();