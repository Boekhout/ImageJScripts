// This script is just to retrieve all the filenames of a specified folder for easy copy and pasting into excell

MyDirectory = getDirectory("");
ListOfFiles = getFileList(MyDirectory);
NumberOfFiles = ListOfFiles.length;

setBatchMode(true);

for (i=0; i<NumberOfFiles; i++) {
	run("Bio-Formats Importer", "open=["+MyDirectory+ListOfFiles[i]+"] color_mode = Composite view=Hyperstack stack_order=XYCZT stitch_tiles");
		ImageName = getTitle();
		print(ImageName);

		run("Close All");
}

