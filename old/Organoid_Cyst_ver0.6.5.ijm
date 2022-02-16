// ----------------------------------------------------------------------------------------------------

// 確認用の画像を個別に出力するかどうか
Mask = false;
Edge = false;
Org1 = false;
Peripheral = true;
Center = false;
Cyst = false;
Result = true;
Org2 = false;

Debug = false; // 確認用の画像を全て出力するかどうか
if (Debug) {
	Mask = true;
	Edge = true;
	Org1 = true;
	Peripheral = true;
	Center = true;
	Cyst = true;
	Result = true;
	Org2 = true;
}

// CSVを出力するかどうか
CSV = false;

// ----------------------------------------------------------------------------------------------------

d = getDirectory("Choose a Directory");
files = getFileList(d);

setBatchMode(true);
run("Set Measurements...", "area centroid fit shape limit redirect=None decimal=2");

// ----------------------------------------------------------------------------------------------------

for (i = 0; i < files.length; i++) {
	fname = d + files[i];
	if (!File.isDirectory(fname)) {
		open(fname);
		run("8-bit");
		
		makeMasks(); // 元画像を残しつつ、基本となるマスク画像を作成する
		
		makeEdges(5, 50); // 輪郭抽出(Find Edges)によるbinary画像の作成 (sigma, rolling)

		// Otsuによるbinary画像と輪郭抽出によるbinary画像を組み合わせて、オルガノイドのbinary画像(Org)を作成する
		imageCalculator("OR create", "Otsu.tif", "Mask of Edge.tif");
		rename("Org.tif");

		findOrg(1); // "Org.tif"をインプットとして、"Org1.tif"を作成する (median)
		Centroid = getCentroid(0.75); // "Results"から、重心を特定するのに必要な値をピクセル数として取得する。Centroid = [Minor, alpha, X, Y]
		//Array.print(Centroid); // ok
		
		findPeripheral(5); // "Org1.tif"とOtsuによるbinary画像を用いて、まず辺縁部のCystを分節化する (mean)

		findCenter(5);// Minimumによるbinary画像を用いて、中心部のCystを分節化する (mean)

		// 辺縁部のCystと中心部のCystを足した画像を作成する
		imageCalculator("OR create", "Center.tif", "Peripheral.tif");
		run("Analyze Particles...", "size=0.02-30 circularity=0-1.00 show=Masks display clear"); // 最終的なcystのサイズの閾値設定
		if (Cyst) {
			saveAs(".tif", fname + "_Cyst.tif");
		}
		rename("Cyst.tif");
		
		if (CSV & isOpen("Results")) { // resultがなければスキップ
			selectWindow("Results");
			saveAs("Results", fname + "_Cyst.csv");
			run("Close"); // 最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく
		} else {
			selectWindow("Results");
			run("Close");
		}

		// Org1の画像とCystの画像を組み合わせて、オルガノイド全体の領域を特定する
		imageCalculator("OR create", "Org1.tif", "Cyst.tif");
		run("Analyze Particles...", "size=30-Infinity show=Masks display clear");
		if (Org2) {
			saveAs(".tif", fname + "_Org2.tif");
		}
		
		if (CSV & isOpen("Results")) { // resultがなければスキップ
			selectWindow("Results");
			Table.sort("Area"); //オブジェクトを2個以上認識した場合に備えて、Areaで昇順にソートしておく
			saveAs("Results", fname + "_Org.csv");
			run("Close"); // 最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく
		} else {
			selectWindow("Results");
			run("Close");
		}

		if (Result) {
			makeResult(); // 最終的な結果の画像を出力する
		}
		
		run("Close");
		run("Close All"); 
	}
}

run("Close All");

// ----------------------------------------------------------------------------------------------------

// 以下に関数
function makeMasks() {
	rename("raw.tif");
	run("Duplicate...", "title=Edge.tif");
	run("Duplicate...", "title=Otsu.tif");
	run("Duplicate...", "title=Minimum.tif");
	
	// Minimumによるbinary画像の作成
	setAutoThreshold("Minimum");
	run("Convert to Mask");

	// 画像の出力の有無	
	if (Mask) {
		saveAs(".tif", fname + "_Minimum.tif");
		rename("Minimum.tif");
	}
	
	// Otsuによるbinary画像の作成
	selectWindow("Otsu.tif");
	setAutoThreshold("Otsu");
	run("Convert to Mask");
	
	// 画像の出力の有無
	if (Mask) {
		saveAs(".tif", fname + "_Otsu.tif");
		rename("Otsu.tif");
	}
}

// ----------------------------------------------------------------------------------------------------

function makeEdges(sigma, rolling) {
	selectWindow("Edge.tif");
	run("Gaussian Blur...", "sigma=sigma"); // 前処理
	run("Find Edges");
	run("Subtract Background...", "rolling=rolling sliding"); // ここでバックグラウンド減算をかける(なるべく幅の狭いEdgeを取得する)
	setAutoThreshold("IsoData dark");
	run("Convert to Mask");
	run("Analyze Particles...", "size=0.2-Infinity show=Masks exclude"); // 整形前に細かい粒子は除いておく
	run("Skeletonize");
	for (j = 0; j < 10; j++) {
		run("Dilate");
	}
	run("Fill Holes"); // Cyst部分を埋める
	for (k = 0; k < 6; k++) {
		run("Erode");
	}

	// 画像の出力の有無
	if (Edge) {
		saveAs(".tif", fname + "_Edge.tif");
		rename("Mask of Edge.tif");
	}
}

// ----------------------------------------------------------------------------------------------------

function findOrg(radius) {
	selectWindow("Org.tif");
	run("Median...", "radius=radius"); //離れた位置にある細かい点はノイズと考えて除去する
	run("Fill Holes");
	run("Analyze Particles...", "size=30-Infinity show=Masks display exclude clear"); // 大きいオブジェクト(=オルガノイド)のみ残す

	// 画像の出力の有無
	if (Org1) {
		saveAs(".tif", fname + "_Org1.tif");
	}
	rename("Org1.tif");
}

// ----------------------------------------------------------------------------------------------------

function getCentroid(alpha) {
	if (isOpen("Results")) { // resultがなければスキップ
		selectWindow("Results");
		Table.sort("Area"); //オブジェクトを2個以上認識した場合に備えて、Areaで昇順にソートしておく
		X = getResult("X", 0); // オルガノイドの幾何学的な重心の座標を取得(inch)
		Y = getResult("Y", 0);
		Minor = getResult("Minor", 0); // Fit ellipseした場合の副軸の長さを取得
		run("Close"); // 最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく

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

function findPeripheral(radius) {
	selectWindow("Org1.tif");
	run("Create Selection");
	selectWindow("Otsu.tif");
	run("Restore Selection");
	run("Clear Outside");
	run("Invert");
	run("Analyze Particles...", "size=0.05-30 circularity=0-1.00 show=Masks"); // 先に細かな粒子を除去する
	run("Mean...", "radius=radius");
	setAutoThreshold("Minimum");
	run("Convert to Mask");
	
	run("Analyze Particles...", "size=0.05-30 circularity=0.1-1.00 show=Masks"); // ある程度大きいCystのみに限定、線状に分節化されてしまったオブジェクトは除去
	
	if (Peripheral) {
		saveAs(".tif", fname + "_Peripheral.tif");
	}
	rename("Peripheral.tif");
}

// ----------------------------------------------------------------------------------------------------

function findCenter(radius) {
	selectWindow("Minimum.tif");
	drawCentroid(Centroid);
	run("Clear Outside");
	run("Invert");
	run("Mean...", "radius=radius");
	setAutoThreshold("Moments");
	run("Convert to Mask");
	
	run("Analyze Particles...", "size=0.2-30 circularity=0.1-1.00 show=Masks"); // ある程度大きいCystのみに限定

	if (Center) {
		saveAs(".tif", fname + "_Center.tif");
	}
	rename("Center.tif");
}

// ----------------------------------------------------------------------------------------------------

function makeResult() {
	selectWindow("Peripheral.tif");
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
	
	selectWindow("Center.tif");
	run("Find Edges");
	setOption("BlackBackground", false);
	run("Dilate");
	run("Create Selection");
	selectWindow("Intermediate.tif");
	run("Restore Selection");
	setForegroundColor(0, 0, 255); // Centerは青で描画
	run("Fill", "slice");
	
	saveAs(".tif", fname + "_Result.tif");
}

// ----------------------------------------------------------------------------------------------------