// ----------------------------------------------------------------------------------------------------

// 設定用
setBatchMode(true);

// 確認用の画像を個別に出力するかどうか
Mask = false;
Edge = false;
Skeleton = false;
Peripheral = false;
Center = true;
Result = true;

// 確認用の画像を全て出力するかどうか
Debug = false;

if (Debug) {
	Mask = true;
	Edge = true;
	Skeleton = true;
	Peripheral = true;
	Center = true;
	Result = true;
}

// CSVを出力するかどうか
CSV = true;

// ----------------------------------------------------------------------------------------------------

d = getDirectory("Choose a Directory");
files = getFileList(d);

run("Set Measurements...", "area centroid fit shape limit redirect=None decimal=2");

// ----------------------------------------------------------------------------------------------------

for (i = 0; i < files.length; i++) {
	fname = d + files[i];
	if (!File.isDirectory(fname)) {
		open(fname);
		run("8-bit");

		processImage(); // メイン関数
		
		run("Close");
		run("Close All"); 
	}
}

run("Close All");

// ----------------------------------------------------------------------------------------------------

function processImage() {
	makeMasks();
	makeEdges(5, 100);
	findOrg(); // Otsuによるbinary画像と輪郭抽出によるbinary画像を組み合わせて、オルガノイドのbinary画像(Org1.tif)を作成する
	closeCyst(); // Org1.tifを入力として、もう少しで閉じそうな辺縁部のCystを閉じて、Org2.tifとして再保存する
	analyseOrg(); // Org2.tifを入力として面積の計測までを行い、"Results"を表示する
	largeCentroid = getCentroid(0.82, true); // "Results"から、重心を特定するのに必要な値をピクセル数として取得する。Centroid = [Minor, alpha, X, Y]
	middleCentroid = getCentroid(0.80, true);
	smallCentroid = getCentroid(0.78, false);
	findPeripheral1(6);
	findPeripheral2(5);
	findCenter(5);

	if (Result) {
		makeResult(); // 最終的な結果の画像を出力する
	}
}

// ----------------------------------------------------------------------------------------------------

// 以下に関数
function makeMasks() {
	rename("raw.tif");
	run("Duplicate...", "title=Edge.tif");
	run("Duplicate...", "title=Otsu.tif");
	
	// Otsuによるbinary画像の作成
	selectWindow("Otsu.tif");
	setAutoThreshold("Otsu");
	run("Convert to Mask");

	run("Fill Holes"); // この時点で閉じられるCystは閉じる
	
	// 画像の出力の有無
	if (Mask) {
		saveAs(".tif", fname + "_Otsu.tif");
		rename("Otsu.tif");
	}
}

// ----------------------------------------------------------------------------------------------------

function removeBorder() { // オルガノイドが画像の上下左右に接してしまっている場合にexcludeされないようにする処理
	makeRectangle(0, 0, 1920, 1);
	run("Clear", "slice");
	makeRectangle(0, 1439, 1920, 1);
	run("Clear", "slice");
	run("Select None"); // ここまで
}

// ----------------------------------------------------------------------------------------------------

function makeEdges(sigma, rolling) {
	selectWindow("Edge.tif");
	run("Gaussian Blur...", "sigma=sigma"); // 前処理
	run("Find Edges");
	run("Subtract Background...", "rolling=rolling sliding"); // ここでバックグラウンド減算をかける
	setAutoThreshold("Otsu dark");
	run("Convert to Mask");
	removeBorder();
	run("Analyze Particles...", "size=0.02-Infinity show=Masks exclude"); // 整形前に細かい粒子は除いておく
	run("Skeletonize");
	run("Dilate"); // 小枝を刈る処理
	for (a = 0; a < 3; a++) {
		run("Median...", "radius=3");
	}

	// 画像の出力の有無
	if (Edge) {
		saveAs(".tif", fname + "_Edge.tif");
		rename("Mask of Edge.tif");
	}
}

// ----------------------------------------------------------------------------------------------------

function findOrg() {
	selectWindow("Mask of Edge.tif");
	//for (b = 0; b < 3; b++) {
		//run("Dilate");
	//}
	run("Analyze Particles...", "size=0.02-Infinity show=Masks exclude"); // 次に細かい粒子は除いておく
	run("Skeletonize");
	imageCalculator("OR create", "Otsu.tif", "Mask of Edge.tif");
	run("Fill Holes"); // ここで閉じられるようになったCystは閉じる
	run("Open");
	removeBorder();
	run("Analyze Particles...", "size=30-Infinity show=Masks exclude");
	rename("Org1.tif");
}

// ----------------------------------------------------------------------------------------------------

function closeCyst() {
	selectWindow("Org1.tif");
	run("Duplicate...", "title=Outline.tif");
	run("Outline");
	for (a = 0; a < 10; a++) {
		run("Dilate");
	}
	run("Skeletonize");
	imageCalculator("OR create", "Outline.tif", "Org1.tif");
	run("Fill Holes");
	// 画像の出力の有無
	if (Mask) {
		saveAs(".tif", fname + "_Org.tif");
	}
	rename("Org2.tif");
}

// ----------------------------------------------------------------------------------------------------

function getCentroid(alpha, next) {
	if (isOpen("Results")) { // resultがなければスキップ
		selectWindow("Results");
		Table.sort("Area"); //オブジェクトを2個以上認識した場合に備えて、Areaで昇順にソートしておく
		X = getResult("X", 0); // オルガノイドの幾何学的な重心の座標を取得(inch)
		Y = getResult("Y", 0);
		Minor = getResult("Minor", 0); // Fit ellipseした場合の副軸の長さを取得

		if (next==false) {
			run("Close"); // 最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく
		}
		
		// inchをピクセル数に変換
		Centroid = newArray(4);
		Centroid[0] = (Minor / 20) * 1920;
		Centroid[1] = alpha; // 円のサイズを決定する定数
		Centroid[2] = (X / 20) * 1920 - (Centroid[0] * alpha / 2); // 円が内接する正方形の左上の座標に変換する
		Centroid[3] = (Y / 15) * 1440 - (Centroid[0] * alpha / 2);
		return Centroid;
	}
}

// ----------------------------------------------------------------------------------------------------

function drawCentroid(Centroid) {
	makeOval(Centroid[2], Centroid[3], Centroid[0] * Centroid[1], Centroid[0] * Centroid[1]);
}

// ----------------------------------------------------------------------------------------------------

function analyseOrg() {
	selectWindow("Org2.tif");
	run("Analyze Particles...", "size=30-Infinity show=Masks display clear");
	
	if (CSV & isOpen("Results")) { // resultがなければスキップ
		selectWindow("Results");
		Table.sort("Area"); //オブジェクトを2個以上認識した場合に備えて、Areaで昇順にソートしておく
		saveAs("Results", fname + "_Org.csv");
		//run("Close"); // Closeしない
	} else {
		if (isOpen("Results")) {
			selectWindow("Results");
			//run("Close");
		}
	}
}

// ----------------------------------------------------------------------------------------------------

function findPeripheral1(sigma) {
	selectWindow("Org2.tif");
	run("Duplicate...", "title=bigOrg.tif"); // 輪郭抽出する範囲は、Orgよりも少し大き目にとる
	for (a = 0; a < 5; a++) {
		run("Dilate");
	}
	run("Create Selection");
	selectWindow("raw.tif");
	run("Duplicate...", "title=Copy1.tif");
	run("Restore Selection");
	run("Clear Outside");
	run("Select None"); // Selectionを先に解除する
	run("Gaussian Blur...", "sigma=sigma"); // 前処理
	run("Find Edges");
	run("Invert");
	run("Subtract Background...", "rolling=100 light sliding");
	setAutoThreshold("Otsu");
	run("Convert to Mask");
	run("Skeletonize");
	// 画像の出力の有無
	if (Skeleton) {
		saveAs(".tif", fname + "_Skeleton1.tif");
		rename("Copy1.tif");
	}

	selectWindow("bigOrg.tif");
	run("Select None"); // Selectionを解除しないと、Duplicateした時にCropされてしまう
	run("Outline");
	for (j = 0; j < 5; j++) {
		run("Dilate");
	}
	run("Create Selection");
	selectWindow("Copy1.tif");
	run("Restore Selection");
	run("Clear", "slice");
	
	// 画像の出力の有無
	if (Skeleton) {
		saveAs(".tif", fname + "_Skeleton2.tif");
	}
	rename("Skeleton.tif");

	run("Select None"); // Selectionを解除しないと、Duplicateした時にCropされてしまう
	run("Duplicate...", "title=Copy2.tif");
	run("Fill Holes");
	run("Open");
	run("Analyze Particles...", "size=0.22-Infinity show=Masks");

	if (Peripheral) {
		saveAs(".tif", fname + "_Peripheral1.tif");
	}
	rename("Peripheral1.tif");
}

// ----------------------------------------------------------------------------------------------------

function findPeripheral2(sigma) {
	selectWindow("Org2.tif");
	run("Create Selection");
	selectWindow("Otsu.tif");
	for (j = 0; j < 5; j++) { // もともとnoisyなCyst以外の辺縁部の明るい領域は、次のOpen処理で大きく削られることになる
		run("Salt and Pepper");
	}
	run("Restore Selection");
	run("Clear Outside");
	run("Invert");
	run("Open");
	run("Median...", "radius=5");
	
	run("Analyze Particles...", "size=0.30-Infinity show=Masks");

	for (k = 0; k < 3; k++) { // 残ったものだけ、整形のための処理をする
		run("Dilate");
	}
	run("Gaussian Blur...", "sigma=sigma");
	setAutoThreshold("Otsu");
	run("Convert to Mask");

	if (Peripheral) {
		saveAs(".tif", fname + "_Peripheral2.tif");
	}
	rename("Peripheral2.tif");
}

// ----------------------------------------------------------------------------------------------------

function findCenter(sigma) {
	selectWindow("raw.tif");
	run("Duplicate...", "title=Copy2.tif");
	drawCentroid(largeCentroid);
	run("Clear Outside");
	run("Gaussian Blur...", "sigma=sigma"); // 前処理
	run("Find Edges");
	run("Invert");
	run("Select None"); // 一旦解除する
	drawCentroid(middleCentroid);
	run("Clear Outside");
	run("Select None");
	saveAs(".tif", fname + "_edgetest.tif");
	//run("Subtract Background...", "rolling=100 light sliding");
	setAutoThreshold("IJ_IsoData");
	run("Convert to Mask");

	run("Fill Holes");

	drawCentroid(smallCentroid);
	run("Clear Outside");
	
	run("Analyze Particles...", "size=0.2-Infinity circularity=0.3-1.00 show=Masks");
	
	if (Center) {
		saveAs(".tif", fname + "_Center.tif");
	}
	rename("Center.tif");
}

// ----------------------------------------------------------------------------------------------------

function makeSmallObject() { // オブジェクトが存在しない場合に備えての処理
	makeRectangle(0, 0, 1, 1);
	setForegroundColor(255, 255, 255);
	run("Draw", "slice");
	run("Select None");
}

// ----------------------------------------------------------------------------------------------------

function makeResult() {	
	selectWindow("Peripheral1.tif");
	makeSmallObject();
	run("Find Edges");
	setOption("BlackBackground", false);
	run("Dilate");
	run("Create Selection");
	selectWindow("raw.tif");
	run("RGB Color");
	run("Restore Selection");
	setForegroundColor(255, 0, 0); // Peripheralは赤で描画
	run("Fill", "slice");
	rename("Intermediate.tif");

	selectWindow("Peripheral2.tif");
	makeSmallObject();
	run("Find Edges");
	setOption("BlackBackground", false);
	run("Dilate");
	run("Create Selection");
	selectWindow("Intermediate.tif");
	run("Restore Selection");
	setForegroundColor(0, 0, 255); // Centerは青で描画
	run("Fill", "slice");

	selectWindow("Center.tif");
	makeSmallObject();
	run("Find Edges");
	setOption("BlackBackground", false);
	run("Dilate");
	run("Create Selection");
	selectWindow("Intermediate.tif");
	run("Restore Selection");
	setForegroundColor(0, 255, 0); // Centerは緑で描画
	run("Fill", "slice");
	
	selectWindow("Org2.tif");
	run("Find Edges");
	setOption("BlackBackground", false);
	run("Dilate");
	run("Create Selection");
	selectWindow("Intermediate.tif");
	run("Restore Selection");
	setForegroundColor(255, 200, 0); // Org2はオレンジで描画
	run("Fill", "slice");

	run("Select None");
	drawCentroid(largeCentroid);
	setForegroundColor(255, 200, 0); // Centroidはオレンジで描画
	run("Draw", "slice");

	run("Select None");
	drawCentroid(smallCentroid);
	setForegroundColor(255, 200, 0); // Centroidはオレンジで描画
	run("Draw", "slice");
	
	saveAs(".tif", fname + "_Result.tif");
}