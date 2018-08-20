// This script is designed by Michiel Boekhout, for accompanying publication. Please feel free to use. 
// Script designed to recognize foci from LEPTOTENE cells from testis spreads, from composite 16-bit 3 Channel images. 
// This macro uses a difference of the gaussians for DMC1, SYCP3 detection is autothresholded using the "Li" algorithm before masking and counting
// The variable of interest depending on your own signal to noise ration is the "noise" in "Find maxima" command. 
// The example protein here is DMC1, but more important is your channel order (Currently Channel 1 expected for SYCP3 staining.)


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
		run("Auto Threshold", "method=Li white");
		//setThreshold(10700, 65000); // attempts with a set threshold were variable, especially between experiments
		run("Convert to Mask");
		run("Analyze Particles...", "clear add in_situ");
		run("Divide...", "value=255.000");

		//Refining the foci and removing background
		selectWindow("C2-"+ImageName);
		rename("DMC1"); // DMC1 is the example, but any foci forming protein could be analyzed with this script.
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
		run("Invert"); // This step was previously not necessary, unclear why version update in ImageJ required this step.
							
		run("Find Maxima...", "noise=200 output=[Point Selection]"); //the noise variable should be adjusted to the specifics of your experiment
		roiManager("Add");
			
		run("Find Maxima...", "noise=200 output=[Count]");

			
		Points = nResults;
			
		run("Merge Channels...", "c1=Sycp3-1 c2=DMC1-1 create");
		selectWindow("Composite");
		
		roiManager("Select", Points);

		Foci = getResult("Count");
		//waitForUser;
		print(ImageName, "	", Foci);

		waitForUser; // at this step, look at the 'Composite image' and manually analyze if the script is performing well. Recommended is to set SYCP3 to either magenta or blue, and foci forming protein to green/yellow/fire LUT.

	roiManager("Reset");
	//run("Clear Results");
	run("Close All");
}