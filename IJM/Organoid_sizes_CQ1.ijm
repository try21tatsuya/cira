d = getDirectory("Choose a Directory");

files = getFileList(d);
setBatchMode(true);
for (i = 0; i < files.length; i++) {
	f = d + files[i];
	if (!File.isDirectory(f)) {
		open(files[i]);
		run("Invert");
		run("Subtract Background...", "rolling=5 sliding");
		setAutoThreshold("Otsu dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Dilate");
		run("Dilate");
		run("Dilate");
		run("Fill Holes");
		run("Erode");
		run("Erode");
		run("Erode");
		run("Watershed"); // バリ取りのため
		run("Set Measurements...", "area fit shape limit redirect=None decimal=2");
		run("Analyze Particles...", "size=2-Infinity show=Masks display clear"); //clearで前回の計測値を消去
		saveAs(".tif", f + "_bin.tif");
		if (isOpen("Results")) { // resultがなければスキップ
			selectWindow("Results");
			Table.sort("Area"); //オブジェクトを2個以上認識した場合に備えて、Areaで昇順にソートしておく
			saveAs("Results", f + ".csv");
			run("Close"); //最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく
		}
		run("Close All");
	}
}

run("Close All");