setBatchMode(true);
d = getDirectory("Choose a Directory");

files = getFileList(d);
for (i = 0; i < files.length; i++) {
	fname = d + files[i];
	if (!File.isDirectory(fname)) {
		open(fname);
		run("8-bit");
		rename("Image_A.tif");
		run("Duplicate...", "title=Image_B.tif");
		
		setAutoThreshold("RenyiEntropy");
		run("Convert to Mask");
		//run("Median...", "radius=3"); //離れた位置にある細かい点はノイズと考えて除去する、このタイミングではない方が良さそうか
		
		selectWindow("Image_A.tif");

		run("Gaussian Blur...", "sigma=5");
		run("Find Edges");
		setAutoThreshold("IsoData dark");
		run("Convert to Mask");
		run("Analyze Particles...", "size=0.05-Infinity show=Masks exclude");
		
		imageCalculator("OR create", "Image_B.tif", "Mask of Image_A.tif");

		selectWindow("Mask of Image_A.tif");
		saveAs(".tif", fname + "_bin.tif");

		selectWindow("Result of Image_B.tif");
		run("Analyze Particles...", "size=30-Infinity show=Masks exclude"); //大きめのオブジェクトのみ残す
		setOption("BlackBackground", false);

		saveAs(".tif", fname + "_bin2.tif");

		run("Erode"); //Image_A由来のエッジを細くする
		run("Analyze Particles...", "size=30-Infinity show=Masks exclude"); //大きめのオブジェクトのみ残す
		setOption("BlackBackground", false);

		run("Mean...", "radius=10");
		setAutoThreshold("MaxEntropy");
		run("Convert to Mask");
		run("Fill Holes");
		saveAs(".tif", fname + "_bin3.tif");

		//run("Fill Holes");

		//run("Fill Holes");
		//rename("Intermediate.tif");
		//run("Set Measurements...", "area shape limit redirect=None decimal=2");
		//run("Analyze Particles...", "size=2-Infinity show=Masks display exclude summarize");
		//selectWindow("Mask of Intermediate.tif");
		//run("Invert");
		//run("Dilate");
		//run("Fill Holes");
		//run("Create Selection");
		//selectWindow("Intermediate.tif");
		//run("Restore Selection");
		//setBackgroundColor(0, 0, 0);
		//run("Clear Outside");
		//run("Analyze Particles...", "size=2-Infinity show=Masks display summarize");

		//selectWindow("Intermediate.tif");
		//run("Close");
		//selectWindow("Mask of Intermediate.tif");
		//run("Close");
		//selectWindow("Results");
		//saveAs("Results", fname + "_result.csv");
		run("Close");
		run("Close All"); 
	}
}

run("Close All"); 
//selectWindow("Summary"); 
//run("Close");