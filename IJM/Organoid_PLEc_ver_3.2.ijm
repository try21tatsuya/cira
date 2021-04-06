input = getDirectory("Choose a Directory");
processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(list[i]))
			processFolder("" + input + list[i]);
		if(!File.isDirectory(list[i]))
			d = input + list[i];
			processFile(d);
	}
}

function processFile(d) {

files = getFileList(d);
for (i = 0; i < files.length; i++) {
	f = d + files[i];
	if (!File.isDirectory(f)) {
		print(f);
		open(f);
		run("8-bit");
	}
}

selectWindow("CH1.tif");

setAutoThreshold("Mean dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Set Measurements...", "area centroid shape limit redirect=None decimal=2");
run("Analyze Particles...", "size=0.03-Infinity show=Masks display clear summarize");
imageCalculator("AND create", "CH1.tif", "Mask of CH1.tif");
selectWindow("CH1.tif");
close();
selectWindow("Result of CH1.tif");
saveAs(".tif", d + "CH1_bin.tif");
selectWindow("Mask of CH1.tif");
run("Create Selection");

selectWindow("CH2.tif");
run("Restore Selection");
run("Clear Outside");

run("Unsharp Mask...", "radius=3 mask=0.6");
setAutoThreshold("IJ_IsoData dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Fill Holes");
//run("Watershed");
run("Analyze Particles...", "size=0.003-Infinity circularity=0.1-1.00 show=Masks display summarize");
imageCalculator("AND create", "CH1_bin.tif", "Mask of CH2.tif");
selectWindow("CH2.tif");
close();
selectWindow("Mask of CH2.tif");
close();
selectWindow("Result of CH1_bin.tif");
saveAs(".tif", d + "CH2_bin.tif");

selectWindow("Mask of CH1.tif");
run("Create Selection");
selectWindow("CH3.tif");
run("Restore Selection");
run("Clear Outside");

setAutoThreshold("Mean dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Analyze Particles...", "size=0.002-Infinity show=Masks display summarize");
imageCalculator("AND create", "CH1_bin.tif", "Mask of CH3.tif");
selectWindow("CH3.tif");
close();
selectWindow("Mask of CH3.tif");
close();
selectWindow("Result of CH1_bin.tif");
saveAs(".tif", d + "CH3_bin.tif");

selectWindow("Mask of CH1.tif");
run("Create Selection");
selectWindow("CH4.tif");
run("Restore Selection");
run("Clear Outside");

run("Unsharp Mask...", "radius=4 mask=0.6");
setAutoThreshold("Percentile dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Analyze Particles...", "size=0.002-Infinity show=Masks display summarize");
imageCalculator("AND create", "CH1_bin.tif", "Mask of CH4.tif");
selectWindow("CH4.tif");
close();
selectWindow("Mask of CH4.tif");
close();
selectWindow("Result of CH1_bin.tif");
saveAs(".tif", d + "CH4_bin.tif");

imageCalculator("AND create", "CH3_bin.tif","CH4_bin.tif");
selectWindow("Result of CH3_bin.tif");
run("Analyze Particles...", "size=0.002-Infinity show=Masks display summarize");
imageCalculator("AND create", "Result of CH3_bin.tif","Mask of Result of CH3_bin.tif");
selectWindow("Result of CH3_bin.tif");
close();
selectWindow("Mask of Result of CH3_bin.tif");
close();
selectWindow("Result of Result of CH3_bin.tif");
saveAs(".tif", d + "CH5_bin.tif");

imageCalculator("Subtract create", "CH4_bin.tif","CH3_bin.tif");
selectWindow("Result of CH4_bin.tif");
run("Analyze Particles...", "size=0.002-Infinity show=Masks display summarize");
imageCalculator("AND create", "Result of CH4_bin.tif","Mask of Result of CH4_bin.tif");
selectWindow("Result of CH4_bin.tif");
close();
selectWindow("Mask of Result of CH4_bin.tif");
close();
selectWindow("Result of Result of CH4_bin.tif");
saveAs(".tif", d + "CH6_bin.tif");

imageCalculator("OR create", "CH3_bin.tif","CH4_bin.tif");
selectWindow("Result of CH3_bin.tif");
run("Analyze Particles...", "size=0.002-Infinity show=Masks display summarize");
imageCalculator("AND create", "Result of CH3_bin.tif","Mask of Result of CH3_bin.tif");
selectWindow("Mask of Result of CH3_bin.tif");
close();
selectWindow("Result of Result of CH3_bin.tif");
saveAs(".tif", d + "CH7_bin.tif");

imageCalculator("OR create", "CH2_bin.tif","Result of CH3_bin.tif");
selectWindow("Result of CH2_bin.tif");
run("Analyze Particles...", "size=0.002-Infinity show=Masks display summarize");
imageCalculator("AND create", "Result of CH2_bin.tif","Mask of Result of CH2_bin.tif");
selectWindow("Result of CH2_bin.tif");
close();
selectWindow("Mask of Result of CH2_bin.tif");
close();
selectWindow("Result of Result of CH2_bin.tif");
saveAs(".tif", d + "CH8_bin.tif");

imageCalculator("AND create", "CH2_bin.tif","Result of CH3_bin.tif");
selectWindow("Result of CH2_bin.tif");
run("Analyze Particles...", "size=0.002-Infinity show=Masks display summarize");
imageCalculator("AND create", "Result of CH2_bin.tif","Mask of Result of CH2_bin.tif");
selectWindow("Result of CH2_bin.tif");
close();
selectWindow("Mask of Result of CH2_bin.tif");
close();
selectWindow("Result of Result of CH2_bin.tif");
saveAs(".tif", d + "CH9_bin.tif");

selectWindow("Mask of CH1.tif");
close();
selectWindow("Result of CH3_bin.tif");
close();

selectWindow("Summary"); 
saveAs("Results", d + "Results.csv");
run("Close All"); 
selectWindow("Results"); 
run("Close");
selectWindow("Log"); 
run("Close");
selectWindow("Results.csv"); 
run("Close");

}