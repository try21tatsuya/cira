input = getDirectory("Choose a Directory");
processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(list[i]))
			processFolder("" + input + list[i]);
		if(!File.isDirectory(list[i]))
			d = input + list[i];
			processFile(d);
	}
}

function processFile(d) {

	files = getFileList(d);
	for (i = 0; i < files.length; i++) {
		f = d + files[i];
		if (!File.isDirectory(f)) {
			print(f);
			open(f);
			run("8-bit");
			makeRectangle(320, 240, 1280, 960); //辺縁1/6ずつをカット
			run("Crop");
		}
	}

	selectWindow("CH1.tif");
	run("Subtract Background...", "rolling=100 sliding"); //少しきつめかも
	
	setAutoThreshold("Otsu dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Set Measurements...", "area redirect=None decimal=2");
	run("Analyze Particles...", "size=0.005-Infinity show=Masks summarize");
	selectWindow("Mask of CH1.tif");
	run("Invert"); //見やすくするため（バックが黒になるように）、一旦invert
	saveAs(".tif", d + "CH1_bin.tif");
	run("Create Selection");
	
	selectWindow("CH2.tif");
	run("Subtract Background...", "rolling=200 sliding"); //一応入れておく	
	run("Restore Selection");
	run("Clear Outside"); //Hoechstに含まれない領域（ゴミなど）はカットする
	run("Select None"); //selectionの解除
	
	setAutoThreshold("Otsu dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Analyze Particles...", "size=0.003-Infinity show=Masks summarize");
	run("Invert"); //見やすくするため（バックが黒になるように）、一旦invert
	saveAs(".tif", d + "CH2_bin.tif");
	
	selectWindow("CH3.tif");
	run("Subtract Background...", "rolling=150 sliding"); //若干緩めに
	
	setAutoThreshold("Triangle dark"); //バックグラウンド減算はあえてしない、やや広めに分節化する
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Dilate"); //穴を埋める
	run("Dilate");
	run("Erode");
	run("Erode");
	run("Analyze Particles...", "size=0.1-Infinity show=Masks summarize"); //小さな領域は除去
	run("Invert"); //見やすくするため（バックが黒になるように）、一旦invert
	saveAs(".tif", d + "CH3_bin.tif");
	
	selectWindow("CH4.tif");
	run("Subtract Background...", "rolling=100 sliding"); //少しきつめかも
	
	setAutoThreshold("Triangle dark"); //やや広めに分節化する
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Dilate"); //穴を埋める
	run("Dilate");
	run("Erode");
	run("Erode");
	run("Analyze Particles...", "size=0.1-Infinity show=Masks summarize"); //小さな領域は除去
	run("Invert"); //見やすくするため（バックが黒になるように）、一旦invert
	saveAs(".tif", d + "CH4_bin.tif");
	
	//invertしていたものを戻す
	selectWindow("CH1_bin.tif");
	run("Select None"); //selectionを解除しないでinvertすると、すべて消えてしまう
	run("Invert");
	selectWindow("CH2_bin.tif");
	run("Invert");
	selectWindow("CH3_bin.tif");
	run("Invert");
	selectWindow("CH4_bin.tif");
	run("Invert");
	
	// EpCAM陽性LTL陽性
	imageCalculator("AND create", "CH3_bin.tif", "CH4_bin.tif");
	selectWindow("Result of CH3_bin.tif"); //同じファイル名ができないように、意識して"AND create"する順番を決めている
	run("Invert");
	run("Analyze Particles...", "size=0.002-Infinity show=Masks summarize");
	run("Invert"); //見やすくするため（バックが黒になるように）、一旦invert
	saveAs(".tif", d + "CH5_bin.tif"); // LTL陽性は、ほぼ100%EpCAM陽性に包含される
	
	selectWindow("CH5_bin.tif"); //CH5_binもInvertを戻す
	run("Invert");

	// EpCAM陽性中のHoechst
	imageCalculator("AND create", "CH1_bin.tif", "CH4_bin.tif");
	selectWindow("Result of CH1_bin.tif"); //同じファイル名ができないように、意識して"AND create"する順番を決めている
	run("Invert");
	run("Analyze Particles...", "size=0.005-Infinity show=Masks summarize");
	run("Invert");
	saveAs(".tif", d + "CH6_bin.tif");

	// EpCAM陽性中のpHH3
	imageCalculator("AND create", "CH4_bin.tif", "CH2_bin.tif");
	selectWindow("Result of CH4_bin.tif"); //同じファイル名ができないように、意識して"AND create"する順番を決めている
	run("Invert");
	run("Analyze Particles...", "size=0.003-Infinity show=Masks summarize");
	run("Invert");
	saveAs(".tif", d + "CH7_bin.tif");

	// EpCAM陽性LTL陽性中のHoechst
	imageCalculator("AND create", "CH5_bin.tif", "CH1_bin.tif");
	selectWindow("Result of CH5_bin.tif"); //同じファイル名ができないように、意識して"AND create"する順番を決めている
	run("Invert");
	run("Analyze Particles...", "size=0.005-Infinity show=Masks summarize");
	run("Invert");
	saveAs(".tif", d + "CH8_bin.tif");

	// EpCAM陽性LTL陽性中のpHH3
	imageCalculator("AND create", "CH2_bin.tif", "CH5_bin.tif");
	selectWindow("Result of CH2_bin.tif"); //同じファイル名ができないように、意識して"AND create"する順番を決めている
	run("Invert");
	run("Analyze Particles...", "size=0.003-Infinity show=Masks summarize");
	run("Invert");
	saveAs(".tif", d + "CH9_bin.tif");

	selectWindow("Summary"); 
	saveAs("Results", d + "Results.csv");
	run("Close All"); //途中の画像もあえて最後まで開きっぱなしにしている
	selectWindow("Log");
	run("Close");
	selectWindow("Results.csv");
	run("Close");

}