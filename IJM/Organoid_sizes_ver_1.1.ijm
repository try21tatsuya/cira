d = getDirectory("Choose a Directory");

files = getFileList(d);
for (i = 0; i < files.length; i++) {
	f = d + files[i];
	if (!File.isDirectory(f)) {
		dpaths = d + files[i];
		open(files[i]);
		run("8-bit");
		setAutoThreshold("RenyiEntropy");
		run("Convert to Mask");
		run("Fill Holes");
		rename("Intermediate.tif");
		run("Set Measurements...", "area shape limit redirect=None decimal=2");
		run("Analyze Particles...", "size=2-Infinity show=Masks display exclude summarize");
		selectWindow("Mask of Intermediate.tif");
		run("Invert");
		run("Dilate");
		run("Fill Holes");
		run("Create Selection");
		selectWindow("Intermediate.tif");
		run("Restore Selection");
		setBackgroundColor(0, 0, 0);
		run("Clear Outside");
		run("Analyze Particles...", "size=2-Infinity show=Masks display summarize");
		saveAs(".tif", dpaths + "_bin.tif");
		
		selectWindow("Intermediate.tif");
		run("Close");
		selectWindow("Mask of Intermediate.tif");
		run("Close");
		selectWindow("Results");
		saveAs("Results", dpaths + "result.csv");
		run("Close");
		run("Close All"); 
	}
}

run("Close All"); 
selectWindow("Summary"); 
run("Close");