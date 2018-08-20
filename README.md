# ImageJScripts
Collection of ImageJ scripts associated with publication (...) 

These scripts were all adapted to be used with Composite 3 channel 16 bit images, of which at least 1 channel contains SYCP3 staining, to be able to determine axis association of foci. 

Normal pipeline would be:
Isolate_SingleCells.ijm to isolate single cells and save these separately in folders per meiotic stage, this is mostly manual work.

If only interested in number of foci, and of the 'FociCount' and indicated meiotic stage should suffice. 

More detailed analysis, such as focus size and intensity, the 'REC114_FOCI_Number_intensity.ijm' will be more suited, and should work sufficiently for different stages up to pachynema. 

For colocalization use 2 Channel_Axis_associated_colocalization.ijm which outputs an excel file with the percentage of colocalization per focus between two channels as defined in the script. 
