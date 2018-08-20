// This script is designed by Michiel Boekhout, for accompanying publication. Please feel free to use. 
// Script designed to recognize foci from LATE ZYOGTENE cells from testis spreads, from composite 16-bit 3-Channel images. 
// Take note in the specifics of SYCP3 detection,  as this is stage specific

MyDirectory = getDirectory("");
ListOfFiles = getFileList(MyDirectory);
NumberOfFiles = ListOfFiles.length;

roiManager("Reset");
run("Clear Results");
run("Close All");

for (i=0; i<NumberOfFiles; i++) {
	run("Bio-Formats Importer", "open=["+MyDirectory+ListOfFiles[i]+"] color_mode = Composite view=Hyperstack stack_order=XYCZT stitch_tiles");
		ImageName = getTitle();
		run("Split Channels");
		selectWindow("C1-"+ImageName);
		rename("Sycp3");
		run("Duplicate...", " ");
		selectWindow("Sycp3");
		run("Auto Threshold", "method=RenyiEntropy white"); // Note that this method of detecting SYCP3 is different from other meiotic stages
		//setThreshold(10700, 65000);
		run("Convert to Mask");
		run("Analyze Particles...", "clear add in_situ");
		run("Divide...", "value=255.000");

		//Refining the foci and removing background
		selectWindow("C2-"+ImageName);
		rename("DMC1");
		run("Remove Outliers...", "radius=1 threshold=50 which=Bright");
		run("Duplicate...", " ");
		run("Duplicate...", " ");
		rename("DMC1-large");
		run("Duplicate...", " ");
		rename("DMC1-small");
		selectWindow("DMC1-large");
		run("Gaussian Blur...", "sigma=2");
		selectWindow("DMC1-small");
		run("Gaussian Blur...", "sigma=0.5");
		imageCalculator("Subtract create", "DMC1-small","DMC1-large");
		imageCalculator("Multiply create 32-bit", "Sycp3","Result of DMC1-small");
		selectWindow("Result of Sycp3");
		rename("Masked");
		run("Invert");
		run("Find Maxima...", "noise=200 output=[Point Selection]");
		roiManager("Add");
		run("Find Maxima...", "noise=200 output=[Count]");
		
		Points = nResults;
			
		run("Merge Channels...", "c1=Sycp3-1 c2=DMC1-1 create");
		selectWindow("Composite");
		
		roiManager("Select", Points);

		Foci = getResult("Count");
		//waitForUser;
		print(ImageName, "	", Foci);

		waitForUser;

	roiManager("Reset");
	//run("Clear Results");
	run("Close All");
}