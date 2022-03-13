d = getDirectory("Choose a Directory");
files = getFileList(d);

setBatchMode(true);
run("Set Measurements...", "area mean standard modal min perimeter fit shape integrated median skewness kurtosis redirect=None decimal=4");

for (i = 0; i < files.length; i++) {
	f = d + files[i];
	if (!File.isDirectory(f)) {
		open(files[i]);
		rename("raw.tif");
		run("Duplicate...", "title=copy.tif");
		run("Invert");
		run("Subtract Background...", "rolling=5 sliding");
		run("Mean...", "radius=15"); //ピントが合っていない画像も分節化できるように、および画像全体が分節化されるケースの予防
		setAutoThreshold("Li dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Analyze Particles...", "size=0.2-Infinity show=Masks"); //Dilateする前に細かな粒子を除いておく
		run("Invert");
		for (j = 0; j < 5; j++) {
			run("Dilate");
		}
		run("Fill Holes");
		for (k = 0; k < 5; k++) {
			run("Erode");
		}
		run("Watershed"); // バリ取りのため
		run("Analyze Particles...", "size=2-Infinity show=Masks");
		run("Invert");
		run("Dilate");
		run("Erode");
		run("Analyze Particles...", "size=2-Infinity show=Masks");
		saveAs(".tif", f + "_bin.tif");
		run("Invert");
		run("Analyze Particles...", "size=2-Infinity show=Masks display clear add"); // ROI Managerに追加する
		if (isOpen("Results")) { // resultがなければ（ROI Managerもないので）スキップ
			selectWindow("Results");
			run("Clear Results"); // resultは一度clearする
			num_roi = roiManager("count"); // ROIの個数を取得
			selectWindow("raw.tif");
			for (l = 0; l < num_roi; l++) {
				roiManager("Select", l);
				roiManager("Measure");
			}
			roiManager("Delete"); // 現在登録されているROIを全て削除する
			selectWindow("Results");
			Table.sort("Area"); //オブジェクトを2個以上認識した場合に備えて、Areaで昇順にソートしておく
			saveAs("Results", f + ".csv");
			run("Close"); //最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく
		}
		run("Close All");
	}
}

run("Close All");