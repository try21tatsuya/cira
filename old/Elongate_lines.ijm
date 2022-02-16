d = getDirectory("Choose a Directory");
files = getFileList(d);

run("Set Measurements...", "area centroid fit shape limit redirect=None decimal=2");

// ----------------------------------------------------------------------------------------------------

for (i = 0; i < files.length; i++) {
	fname = d + files[i];
	if (!File.isDirectory(fname)) {
		open(fname);
		
		run("Skeletonize");
		rename("Start.tif");
		run("Duplicate...", "title=Cyst1pre.tif");
		run("Fill Holes");
		run("Open");
		run("Analyze Particles...", "size=0.2-Infinity show=Masks");
		saveAs(".tif", fname + "_Cyst1.tif");
		rename("Cyst1.tif");
		run("Create Selection");
		selectWindow("Start.tif");
		run("Duplicate...", "title=Cyst2pre.tif");
		run("Restore Selection");
		run("Clear", "slice");
		run("Select None");
		
		for (j = 0; j < 30; j++) {
			for (a = 0; a < 3; a++) {
				run("Dilate");
			}
			run("Skeletonize");
		}
		run("Fill Holes");
		run("Open");
		run("Analyze Particles...", "size=0.2-Infinity show=Masks");
		imageCalculator("OR create", "Cyst1.tif", "Mask of Cyst2pre.tif");
		
		saveAs(".tif", fname + "_Cyst2.tif");
		rename("Cyst2.tif");

		run("Create Selection");
		selectWindow("Start.tif");
		run("Duplicate...", "title=Cyst3pre.tif");
		run("Restore Selection");
		run("Clear", "slice");
		run("Select None");
		
		for (k = 0; k < 30; k++) {
			for (b = 0; b < 10; b++) {
				run("Dilate");
			}
			run("Skeletonize");
		}
		run("Fill Holes");
		run("Open");
		run("Analyze Particles...", "size=0.8-Infinity show=Masks");
		imageCalculator("OR create", "Cyst2.tif", "Mask of Cyst3pre.tif");
		
		saveAs(".tif", fname + "_Cyst3.tif");
		
		run("Close");
		run("Close All"); 
	}
}

run("Close All");