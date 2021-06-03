d = getDirectory("Choose a Directory");
files = getFileList(d);

setBatchMode(true);
run("Set Measurements...", "area fit shape limit redirect=None decimal=2");

for (i = 0; i < files.length; i++) {
	f = d + files[i];
	if (!File.isDirectory(f)) {
		open(files[i]);
		run("Invert");
		run("Subtract Background...", "rolling=5 sliding");
		run("Mean...", "radius=15"); //ピントが合っていない画像も分節化できるように、および画像全体が分節化されるケースの予防
		setAutoThreshold("Li dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Analyze Particles...", "size=0.2-Infinity show=Masks clear"); //Dilateする前に細かな粒子を除いておく
		run("Invert");
		for (j = 0; j < 5; j++) {
			run("Dilate");
		}
		run("Fill Holes");
		for (j = 0; j < 5; j++) {
			run("Erode");
		}
		run("Watershed"); // バリ取りのため
		run("Analyze Particles...", "size=2-Infinity show=Masks clear");
		run("Invert");
		run("Dilate");
		run("Erode");
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