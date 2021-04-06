d = getDirectory("Choose a Directory");

files = getFileList(d);
for (i = 0; i < files.length; i++) {
	f = d + files[i];
	if (!File.isDirectory(f)) {
		open(files[i]);
		run("8-bit");
		run("Unsharp Mask...", "radius=1 mask=0.60");
		run("Subtract Background...", "rolling=5 sliding");
		setAutoThreshold("Triangle");
		//run("Threshold...");
		//setThreshold(0, 10);
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Dilate");
		run("Dilate");
		run("Erode");
		run("Set Measurements...", "area limit redirect=None decimal=2");
		run("Analyze Particles...", "size=0.03-Infinity show=Masks display summarize");
		run("Invert");
		saveAs(".tif", f + "_bin.tif");
		selectWindow("Summary");
		saveAs("Results", f + "result.csv");
		run("Close");
	}
	run("Close All"); 
}

run("Close All"); 
selectWindow("Results"); 
run("Close");