d = getDirectory("Choose a Directory");

files = getFileList(d);
for (i = 0; i < files.length; i++) {
	f = d + files[i];
	if (!File.isDirectory(f)) {
		open(files[i]);
		run("Size...", "width=960 height=720 depth=1 constrain average interpolation=Bilinear"); //このサイズにしないと、空のwellがうまく計測されない
		run("8-bit");
		run("Invert");
		run("Subtract Background...", "rolling=100 sliding"); //プレートの汚れを消すために、きつめにバックグラウンド減算した方が良さそう
		run("Unsharp Mask...", "radius=1 mask=0.9"); //きつくしてみた。
		setAutoThreshold("Otsu dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Set Measurements...", "area fit shape limit redirect=None decimal=2");
		run("Analyze Particles...", "size=0-48 show=Masks"); //細かい粒子は残しておく。表示上の長さ(inches)が2倍になっているため、面積を4倍
		run("Invert");
		run("Dilate");
		run("Dilate");
		run("Dilate");
		run("Fill Holes"); // Dilateした状態でfill holes
		run("Erode");
		run("Erode");
		run("Erode");
		run("Analyze Particles...", "size=0.4-48 show=Masks display clear"); //clearで1回目の結果（1回目は'display'していないが、裏で記録されている）を消去
		saveAs(".tif", f + "_bin.tif");
		if (isOpen("Results")) { // resultがなければスキップ
			selectWindow("Results");
			Table.sort("Area"); //オブジェクトを2個以上認識した場合に備えて、Areaで昇順にソートしておく（やや時間がかかる印象あり）
			saveAs("Results", f + ".csv");
			run("Close"); //最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく
		}
		run("Close All");
	}
}

run("Close All");