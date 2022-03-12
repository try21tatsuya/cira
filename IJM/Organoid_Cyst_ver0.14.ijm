// ----------------------------------------------------------------------------------------------------

// 設定用
setBatchMode(true);

// 確認用の画像を個別に出力するかどうか
Mask = false;
Edge = false;
Skeleton = false;
Peripheral = false;
Center = false;
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
		run("Close All"); 
	}
}

run("Close All");

// ----------------------------------------------------------------------------------------------------

function processImage() {
	makeMasks();
	makeEdges();
	findOrg(); // OtsuとEdgeを組み合わせて、オルガノイドのbinary画像(Org1.tif)を作成する
	findNotOrg();
	closeCyst(); // Org1を入力として、もう少しで閉じそうな辺縁部のCystを閉じる
	analyseOrg(); // さらにオルガノイドの面積の計測までを行いOrg2として保存し、Resultsを表示する
	largeCentroid = getCentroid(0.84, true); // "Results"から、重心を特定するのに必要な値をピクセル数として取得する。Centroid = [Minor, alpha, X, Y]
	middleCentroid = getCentroid(0.79, true);
	smallCentroid = getCentroid(0.78, false);
	findPeripheral1(7);
	findPeripheral2(12);
	findCenter(6);
	analyseCyst();

	if (Result) {
		makeResult(); // 最終的な結果の画像を出力する
	}
}

// ----------------------------------------------------------------------------------------------------

// 以下に関数
function makeMasks() {
	rename("raw.tif");
	run("Duplicate...", "title=Copy1.tif");
	run("Duplicate...", "title=Copy2.tif");
	
	// Otsuによるbinary画像の作成
	setAutoThreshold("Otsu");
	run("Convert to Mask");
	
	// 画像の出力の有無
	if (Mask) {
		saveAs(".tif", fname + "_Otsu.tif");
	}
	rename("Otsu.tif");
}

// ----------------------------------------------------------------------------------------------------

function removeBorder() { // オルガノイドが画像の「中央付近で」上下左右に接してしまっている場合にexcludeされないようにする処理
	makeRectangle(300, 0, 1320, 1);
	run("Clear", "slice");
	makeRectangle(300, 1439, 1320, 1);
	run("Clear", "slice");
	run("Select None"); // ここまで
}

// ----------------------------------------------------------------------------------------------------
function makeEdges() {
	selectWindow("Copy1.tif");
	run("Unsharp Mask...", "radius=1 mask=0.60"); // 前処理
	run("Gaussian Blur...", "sigma=5");
	run("Find Edges");
	run("Subtract Background...", "rolling=100 sliding"); // ここでバックグラウンド減算をかける
	setAutoThreshold("Otsu dark");
	run("Convert to Mask");
	removeBorder();
	run("Analyze Particles...", "size=0.02-Infinity show=Masks exclude"); // 整形前に細かい粒子は除いておく
	run("Skeletonize");
	run("Dilate"); // 小枝を刈る処理
	for (a = 0; a < 3; a++) {
		run("Median...", "radius=3");
	}
	for (b = 0; b < 3; b++) {
		run("Dilate");
	}
	run("Skeletonize");

	// 画像の出力の有無
	if (Edge) {
		saveAs(".tif", fname + "_Edge.tif");
	}
	rename("Edge.tif");
}

// ----------------------------------------------------------------------------------------------------

function findOrg() {
	selectWindow("Otsu.tif");
	run("Duplicate...", "title=Otsu1.tif");	
	imageCalculator("OR create", "Otsu1.tif", "Edge.tif");
	run("Fill Holes"); // ここで閉じられるようになったCystも閉じる
	run("Open");
	run("Analyze Particles...", "size=25-Infinity show=Masks");
	// 画像の出力の有無
	if (Mask) {
		saveAs(".tif", fname + "_Org1.tif");
	}
	rename("Org1.tif");
}

// ----------------------------------------------------------------------------------------------------

function findNotOrg() {
	selectWindow("raw.tif");
	run("Duplicate...", "title=notOrg1.tif");
	run("Unsharp Mask...", "radius=2 mask=0.60");
	setAutoThreshold("Otsu");
	run("Convert to Mask");
	run("Analyze Particles...", "size=0.02-Infinity show=Masks"); // 最初に細かい粒子は除去する
	run("Median...", "radius=3"); // 大まかな形を特定する
	run("Options...", "iterations=1 count=1 pad do=Nothing");
	for (a = 0; a < 3; a++) {
		run("Erode");
	}
	run("Gaussian Blur...", "sigma=5"); // ぼかしが強いとOrgとnotOrgが融合してExludeされてしまう
	setAutoThreshold("Shanbhag");
	run("Convert to Mask");
	for (b = 0; b < 4; b++) {
		run("Erode");
	}
	run("Options...", "iterations=1 count=1 do=Nothing");
	run("Analyze Particles...", "size=0.2-Infinity show=Masks"); // 小さい孤立した領域は無視する
	run("Duplicate...", "title=notOrg2.tif");
	removeBorder();
	run("Analyze Particles...", "size=20-Infinity show=Masks exclude");
	run("Create Selection");
	selectWindow("Mask of Mask of notOrg1.tif");
	run("Restore Selection");
	run("Clear", "slice");
	run("Select None");
	for (c = 0; c < 30; c++) {
		run("Dilate");
	}
	run("Fill Holes");
	makeSmallObject(); // オブジェクトがなかった場合に備えて、makeSmallObjectしておく

	// 画像の出力の有無
	if (Mask) {
		saveAs(".tif", fname + "_notOrg.tif");
	}
	rename("notOrg.tif");
}

// ----------------------------------------------------------------------------------------------------

function closeCyst() {
	selectWindow("notOrg.tif"); // 最初にnotOrgの領域を削除する
	run("Create Selection");
	selectWindow("Org1.tif");
	run("Restore Selection");
	run("Clear", "slice");
	run("Select None");
	run("Duplicate...", "title=Outline.tif");
	run("Outline");
	for (a = 0; a < 20; a++) {
		run("Dilate");
	}
	run("Skeletonize");
	imageCalculator("OR create", "Outline.tif", "Org1.tif");
	run("Fill Holes");
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
	selectWindow("Result of Outline.tif");
	removeBorder();
	run("Analyze Particles...", "size=25-Infinity show=Masks display exclude clear");

	// 画像の出力の有無
	if (Mask) {
		saveAs(".tif", fname + "_Org2.tif");
	}
	rename("Org2.tif");
	
	if (CSV & isOpen("Results")) { // resultがなければスキップ
		selectWindow("Results");
		Table.sort("AR"); //オブジェクトを2個以上認識した場合に備えて、ARで昇順にソートしておく
		saveAs("Results", fname + "_Org.csv");
	} else {
		if (isOpen("Results")) {
			selectWindow("Results");
		}
	}
}

// ----------------------------------------------------------------------------------------------------

function findPeripheral1(sigma) {
	selectWindow("Org2.tif");
	run("Duplicate...", "title=bigOrg.tif"); // 輪郭抽出する範囲は、Orgよりも少し大き目にとる
	for (a = 0; a < 4; a++) {
		run("Dilate");
	}
	run("Create Selection");
	selectWindow("raw.tif");
	run("Duplicate...", "title=Copy3.tif");
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
	}
	rename("Skeleton1.tif");
	
	selectWindow("bigOrg.tif");
	run("Select None"); // Selectionを解除しないと、Duplicateした時にCropされてしまう
	run("Outline");
	for (j = 0; j < 6; j++) {
		run("Dilate");
	}
	run("Create Selection");
	selectWindow("Skeleton1.tif");
	run("Restore Selection");
	run("Clear", "slice");
	
	// 画像の出力の有無
	if (Skeleton) {
		saveAs(".tif", fname + "_Skeleton2.tif");
	}
	rename("Skeleton2.tif");

	run("Select None"); // Selectionを解除しないと、Duplicateした時にCropされてしまう
	run("Duplicate...", "title=Skeleton3.tif");
	run("Fill Holes");
	run("Open");
	run("Analyze Particles...", "size=0.35-Infinity show=Masks");

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
	for (j = 0; j < 8; j++) { // もともとnoisyなCyst以外の辺縁部の明るい領域は、次のOpen処理で大きく削られることになる（7は必要そう）
		run("Salt and Pepper");
	}
	run("Restore Selection");
	run("Clear Outside");
	run("Invert");
	run("Open");
	run("Median...", "radius=3");
	
	run("Analyze Particles...", "size=0.50-Infinity show=Masks");

	run("Gaussian Blur...", "sigma=sigma");
	setAutoThreshold("Otsu");
	run("Convert to Mask");
	
	for (k = 0; k < 5; k++) { // 残ったものだけ、整形のための処理をする
		run("Dilate");
	}
	run("Fill Holes");

	if (Peripheral) {
		saveAs(".tif", fname + "_Peripheral2.tif");
	}
	rename("Peripheral2.tif");
}

// ----------------------------------------------------------------------------------------------------

function findCenter(sigma) {
	selectWindow("raw.tif");
	run("Duplicate...", "title=Copy4.tif");
	drawCentroid(largeCentroid);
	run("Clear Outside");
	run("Gaussian Blur...", "sigma=sigma"); // 前処理
	run("Find Edges");
	run("Invert");
	run("Select None"); // 一旦解除する
	drawCentroid(middleCentroid);
	run("Clear Outside");
	run("Select None");
	setAutoThreshold("IJ_IsoData");
	run("Convert to Mask");

	run("Fill Holes");

	drawCentroid(smallCentroid);
	run("Clear Outside");
	
	run("Analyze Particles...", "size=0.5-Infinity circularity=0.35-1.00 show=Masks"); // 大きめのオブジェクトのみに限定
	
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

function analyseCyst() {
	imageCalculator("OR create", "Center.tif", "Peripheral2.tif");
	imageCalculator("OR create", "Result of Center.tif", "Peripheral1.tif");
	run("Analyze Particles...", "size=0-Infinity circularity=0-1.00 show=Masks display clear"); // 最終的なcystのサイズの閾値設定

	if (CSV & isOpen("Results")) { // resultがなければスキップ
		selectWindow("Results");
		saveAs("Results", fname + "_Cyst.csv");
		run("Close"); // 最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく
	} else {
		if (isOpen("Results")) {
			selectWindow("Results");
			run("Close");
		}
	}
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

	selectWindow("notOrg.tif");
	run("Find Edges");
	run("Create Selection");
	selectWindow("Intermediate.tif");
	run("Restore Selection");
	setForegroundColor(100, 0, 100); // notOrgは紫で描画
	run("Draw", "slice");
	
	run("Select None");
	drawCentroid(largeCentroid);
	setForegroundColor(255, 200, 0); // Centroidはオレンジで描画
	run("Draw", "slice");

	run("Select None");
	drawCentroid(smallCentroid);
	setForegroundColor(255, 200, 0); // Centroidはオレンジで描画
	run("Draw", "slice");
	
	run("Select None");
	
	saveAs(".tif", fname + "_Result.tif");
}