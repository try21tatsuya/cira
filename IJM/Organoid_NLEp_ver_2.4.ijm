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
	run("Set Measurements...", "area shape limit redirect=None decimal=2");
	run("Analyze Particles...", "size=0.03-Infinity show=Masks summarize");
	selectWindow("CH1.tif");
	close();
	selectWindow("Mask of CH1.tif");
	run("Invert");
	saveAs(".tif", d + "CH1_bin.tif");
	run("Create Selection");

	selectWindow("CH2.tif");
	run("Restore Selection");
	run("Clear Outside");

	run("Unsharp Mask...", "radius=3 mask=0.7");
	setAutoThreshold("Triangle dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	selectWindow("CH1_bin.tif");
	run("Select None");
	run("Duplicate...", " ");
	run("Erode");
	run("Create Selection");
	selectWindow("CH2.tif");
	run("Restore Selection");
	run("Analyze Particles...", "size=0.003-Infinity show=Masks summarize");
	run("Invert");
	saveAs(".tif", d + "CH2_bin.tif");

	selectWindow("CH1_bin.tif");
	run("Create Selection");
	selectWindow("CH3.tif");
	run("Restore Selection");
	run("Clear Outside");

	run("Unsharp Mask...", "radius=3 mask=0.7");
	setAutoThreshold("IJ_IsoData dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Analyze Particles...", "size=0.002-Infinity show=Masks summarize");
	run("Invert");
	saveAs(".tif", d + "CH3_bin.tif");

	selectWindow("CH1_bin.tif");
	run("Create Selection");
	selectWindow("CH4.tif");
	run("Restore Selection");
	run("Clear Outside");

	run("Unsharp Mask...", "radius=3 mask=0.7");
	setAutoThreshold("Li dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Analyze Particles...", "size=0.002-Infinity show=Masks summarize");
	run("Invert");
	saveAs(".tif", d + "CH4_bin.tif");

	selectWindow("CH2_bin.tif");
	run("Invert");
	selectWindow("CH3_bin.tif");
	run("Invert");
	selectWindow("CH4_bin.tif");
	run("Invert");

	imageCalculator("AND create", "CH3_bin.tif", "CH4_bin.tif");
	selectWindow("Result of CH3_bin.tif");
	run("Invert");
	run("Analyze Particles...", "size=0.002-Infinity show=Masks summarize");
	run("Invert");
	saveAs(".tif", d + "CH5_bin.tif");

	imageCalculator("Subtract create", "CH4_bin.tif", "CH3_bin.tif");
	selectWindow("Result of CH4_bin.tif");
	run("Invert");
	run("Analyze Particles...", "size=0.002-Infinity show=Masks summarize");
	run("Invert");
	saveAs(".tif", d + "CH6_bin.tif");

	imageCalculator("OR create", "CH2_bin.tif", "CH4_bin.tif");
	selectWindow("Result of CH2_bin.tif");
	run("Invert");
	run("Analyze Particles...", "size=0.002-Infinity show=Masks summarize");
	run("Invert");
	saveAs(".tif", d + "CH7_bin.tif");

	selectWindow("Summary"); 
	saveAs("Results", d + "Results.csv");
	run("Close All"); 
	selectWindow("Log"); 
	run("Close");
	selectWindow("Results.csv"); 
	run("Close");

}