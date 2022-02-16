d = getDirectory("Choose a Directory");
files = getFileList(d);

setBatchMode(true);
run("Set Measurements...", "area fit shape limit redirect=None decimal=2");

for (i = 0; i < files.length; i++) {
	fname = d + files[i];
	if (!File.isDirectory(fname)) {
		open(fname);
		run("8-bit");
		rename("raw.tif");
		run("Duplicate...", "title=Image_B.tif");
		run("Duplicate...", "title=Image_A.tif");
		
		setAutoThreshold("Otsu");
		run("Convert to Mask");
		
		selectWindow("Image_B.tif");

		run("Gaussian Blur...", "sigma=5");
		run("Find Edges");
		setAutoThreshold("IsoData dark");
		run("Convert to Mask");
		run("Skeletonize");
		run("Analyze Particles...", "size=0.01-Infinity show=Masks exclude");
		run("Dilate");
		for (j = 0; j < 2; j++) {
			run("Median...", "radius=3"); // 枝を刈る
		}
		for (k = 0; k < 5; k++) {
			run("Dilate");
		}
		run("Fill Holes");
		for (l = 0; l < 6; l++) { // Fill Holesされなかった線は消える
			run("Erode");
		}
		
		imageCalculator("OR create", "Image_A.tif", "Mask of Image_B.tif");

		selectWindow("Mask of Image_B.tif");
		saveAs(".tif", fname + "_B.tif");

		selectWindow("Result of Image_A.tif");
		run("Median...", "radius=3"); //離れた位置にある細かい点はノイズと考えて除去する
		run("Fill Holes"); // Analyze Particlesの後の方がいいかも
		run("Analyze Particles...", "size=30-Infinity show=Masks display exclude clear"); //大きめのオブジェクトのみ残す
		setOption("BlackBackground", false);

		saveAs(".tif", fname + "_Org.tif");

		if (isOpen("Results")) { // resultがなければスキップ
			selectWindow("Results");
			Table.sort("Area"); //オブジェクトを2個以上認識した場合に備えて、Areaで昇順にソートしておく
			saveAs("Results", fname + "_Org.csv");
			run("Close"); //最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく
		}

		

		
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