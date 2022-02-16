d = getDirectory("Choose a Directory");
files = getFileList(d);

setBatchMode(true);
run("Set Measurements...", "area centroid fit shape limit redirect=None decimal=2");

for (i = 0; i < files.length; i++) {
	fname = d + files[i];
	if (!File.isDirectory(fname)) {
		open(fname);
		run("8-bit");
		rename("Image_B.tif");
		run("Duplicate...", "title=Image_A.tif");
		
		setAutoThreshold("Otsu");
		run("Convert to Mask");

		selectWindow("Image_B.tif");

		run("Gaussian Blur...", "sigma=5");
		run("Find Edges");
		run("Subtract Background...", "rolling=50 sliding"); // ここでバックグラウンド減算
		setAutoThreshold("IsoData dark");
		run("Convert to Mask");
		run("Analyze Particles...", "size=0.2-Infinity show=Masks exclude");
		for (j = 0; j < 5; j++) {
			run("Dilate");
		}
		run("Fill Holes");
		for (k = 0; k < 5; k++) {
			run("Erode");
		}
		
		imageCalculator("OR create", "Image_A.tif", "Mask of Image_B.tif");

		selectWindow("Mask of Image_B.tif");
		saveAs(".tif", fname + "_B.tif");

		selectWindow("Result of Image_A.tif");
		run("Median...", "radius=3"); //離れた位置にある細かい点はノイズと考えて除去する
		run("Analyze Particles...", "size=30-Infinity show=Masks display exclude clear"); //大きめのオブジェクトのみ残す
		run("Fill Holes");

		saveAs(".tif", fname + "_Org.tif");
		rename("Org.tif");

		if (isOpen("Results")) { // resultがなければスキップ
			selectWindow("Results");
			Table.sort("Area"); //オブジェクトを2個以上認識した場合に備えて、Areaで昇順にソートしておく
			saveAs("Results", fname + "_Org.csv");
			X = getResult("X", 1); // オルガノイドの幾何学的な重心の座標を取得(inch)
			Y = getResult("Y", 1);
			Minor = getResult("Minor", 1); // Fit ellipseした場合の副軸の長さを取得
			run("Close"); //最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく
		}
		
		run("Create Selection");
		selectWindow("Image_A.tif");
		saveAs(".tif", fname + "_A.tif"); // SelectWindowが済んでからrenameして保存
		run("Restore Selection");
		run("Clear Outside");
		run("Invert");
		run("Analyze Particles...", "size=0.05-30 circularity=0-1.00 show=Masks");
		run("Fill Holes");
		run("Analyze Particles...", "size=0.05-30 circularity=0.1-1.00 show=Masks display clear");
		
		saveAs(".tif", fname + "_Cyst1.tif");
		
		if (isOpen("Results")) { // resultがなければスキップ
			selectWindow("Results");
			saveAs("Results", fname + "_Cyst1.csv");
			run("Close"); //最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく
		}

		selectWindow("Org.tif");
		run("Select None"); //Selectionを解除ないと、変な形にcropされてしまう
		run("Duplicate...", "title=Org2.tif");
		for (l = 0; l < 50; l++) {
			run("Erode");
		}
		saveAs(".tif", fname + "_Org2.tif");
		
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