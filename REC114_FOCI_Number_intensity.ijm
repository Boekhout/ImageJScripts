// This script is designed by Michiel Boekhout, for accompanying publication. Please feel free to use. 
// Script designed to recognize foci on SYCP3 axis from composite 16-bit 3 Channel images. 
// This macro uses a difference of the gaussians for foci detection, SYCP3 detection is autothresholded using the "Phansalkar" algorithm before masking which seems to work well regardless of meiotic stage. 
// This script outputs several excel files, and also save all Regions of interest per channel that are determined, so you can load these onto your image to see what is detected. 
// If requested, I will consider making a screencast to show the easiest way of determining whether or not this algorithm is working well. 


MyDirectory = getDirectory("Where yo files at dawg?");
output = getDirectory("Choose where to SAVE the ROIs and Excell");
ListOfFiles = getFileList(MyDirectory);
NumberOfFiles = ListOfFiles.length;

roiManager("Reset");
run("Clear Results");
run("Close All");

setBatchMode(true);

for (i=0; i<NumberOfFiles; i++) {
	run("Bio-Formats Importer", "open=["+MyDirectory+ListOfFiles[i]+"] color_mode = Composite view=Hyperstack stack_order=XYCZT stitch_tiles");
		ImageName = getTitle();
		print(ImageName);
		run("Split Channels");
		selectWindow("C3-"+ImageName);
		rename("Sycp3");
		run("Duplicate...", " ");
		selectWindow("Sycp3");
		run("Subtract Background...", "rolling=50 sliding");
		run("Gaussian Blur...", "sigma=1");
		run("8-bit");
		run("Auto Local Threshold", "method=Phansalkar radius=15 parameter_1=0 parameter_2=0 white");
		run("Convert to Mask");
		run("Analyze Particles...", "clear add in_situ");
		roiManager("Select All");
		if (roiManager("count")>0) roiManager("Save", output+ImageName+"sycp3.zip");
		run("Divide...", "value=255.000");
		

		//Refining Rec114 foci and removing background
		selectWindow("C1-"+ImageName);
		rename("Rec114");
		run("Remove Outliers...", "radius=1 threshold=50 which=Bright");
		run("Duplicate...", " ");
		run("Duplicate...", " ");
		rename("Rec114-large");
		run("Duplicate...", " ");
		rename("Rec114-small");
		selectWindow("Rec114-large");
		run("Gaussian Blur...", "sigma=2");
		selectWindow("Rec114-small");
		run("Gaussian Blur...", "sigma=0.5");
		imageCalculator("Subtract create", "Rec114-small","Rec114-large");

		//This is to analyze all Rec114 foci, regardless of axis, so beware of background
		run("Duplicate...", " ");
		rename("Rec_foci");
		setThreshold(40, 65535); // DETERMINE OPTIMAL THRESHOLD FOR YOUR PURPOSE
		run("Convert to Mask");
		run("Watershed");
		roiManager("Reset");
		run("Analyze Particles...", "size=10-Infinity pixel exclude clear add in_situ"); // should introduce upper boundary?
		run("Set Measurements...", "area mean modal min shape integrated median area_fraction limit redirect=None decimal=2");
		rec114foci = nResults;
		countRec=roiManager("count"); 
		arrayRec=newArray(countRec); 
				for(k=0; k<countRec;k++) { 
        		arrayRec[k] = k; 
		} 
		selectWindow("Rec114"); //Note a small background correction has been made to this image, probably trivial
		roiManager("Select", arrayRec);
		Rec114 = roiManager("Measure");
		//print(Rec114);
		
		//splitDir = MyDirectory+"/Results/";
		//File.makeDirectory(splitDir);
		resultsfile = "Rec114"+File.nameWithoutExtension+"_results.xls";
		rec114foci = nResults;
		print("All Foci in image"+" "+rec114foci);

		selectWindow("Results");
		saveAs("text", output+resultsfile);
		
		//Save RoiFile
		roiManager("Select All");
		if (roiManager("count")>0) roiManager("Save", output+ImageName+"Rec114_ROIs.zip");

		//the following code is to select only for Rec114 foci overlapping with axis
		selectWindow("Rec_foci");
		imageCalculator("Multiply create", "Sycp3","Rec_foci");
		selectWindow("Result of Sycp3");
		rename("Masked-Rec114");
		run("Duplicate...", " ");
		rename("Rec114_T");
		run("Analyze Particles...", "size=10-Infinity pixel exclude clear add in_situ"); // should introduce upper boundary?

		run("Set Measurements...", "area mean modal min shape integrated median area_fraction limit redirect=None decimal=2");
		rec114fociAxis = nResults;
		countRecaxis=roiManager("count"); 
		arrayRecaxis=newArray(countRecaxis); 
				for(j=0; j<countRecaxis;j++) { 
        		arrayRecaxis[j] = j; 
		} 
		selectWindow("Rec114");
		roiManager("Select", arrayRecaxis);
		Rec114Axis = roiManager("Measure");
		//print(Rec114Axis);
		
		results_fileaxis = "Rec114Axis"+File.nameWithoutExtension+"_Rec114Axisresults.xls";
		rec114fociAxis = nResults;
		print("Foci on axis"+" "+rec114fociAxis);

		selectWindow("Results");
		saveAs("text", output+results_fileaxis);

		roiManager("Select All");
		if (roiManager("count")>0) roiManager("Save", output+ImageName+"Rec114Axis_ROIs.zip");
		

		//Refining Ankrd31 foci and removing background,currently identical to Rec114 foci
		selectWindow("C2-"+ImageName);
		rename("Ankrd");
		run("Remove Outliers...", "radius=1 threshold=50 which=Bright");
		run("Duplicate...", " ");
		run("Duplicate...", " ");
		rename("Ankrd-large");
		run("Duplicate...", " ");
		rename("Ankrd-small");
		selectWindow("Ankrd-large");
		run("Gaussian Blur...", "sigma=2");
		selectWindow("Ankrd-small");
		run("Gaussian Blur...", "sigma=0.5");
		imageCalculator("Subtract create", "Ankrd-small","Ankrd-large");

		run("Duplicate...", " ");
		rename("Ankrd31_foci");
		run("Auto Threshold", "method=Otsu white"); // Note: Auto Thresholding is not compatible with intensity measurements in that same channel. 
		run("Analyze Particles...", "size=3-Infinity pixel clear add in_situ");
				
		imageCalculator("Multiply create 32-bit", "Sycp3","Result of Ankrd-small");
		selectWindow("Result of Sycp3");
		rename("Masked-Ankrd31");
		run("Duplicate...", " ");
		rename("Ankrd31_T");
		run("8-bit");
		run("Auto Threshold", "method=Huang white");
			
		run("Merge Channels...", "c1=Rec114-1 c2=Ankrd-1 c3=Sycp3-1 create");
		selectWindow("Composite");
		
		//Points = nResults;
		//roiManager("Select", Points);

		//Foci = getResult("Count");
		//print(ImageName, "	", Foci);

		waitForUser;
		roiManager("Reset");
		run("Clear Results");
	run("Close All");
}