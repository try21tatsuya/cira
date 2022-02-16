d = getDirectory("Choose a Directory");
files = getFileList(d);

setBatchMode(true);
run("Set Measurements...", "area centroid fit shape limit redirect=None decimal=2");

for (i = 0; i < files.length; i++) {
	fname = d + files[i];
	if (!File.isDirectory(fname)) {
		open(fname);
		run("8-bit");
		rename("Edge.tif");
		run("Duplicate...", "title=Otsu.tif");
		run("Duplicate...", "title=Minimum.tif");

		// Minimumによるbinary画像の作成
		setAutoThreshold("Minimum");
		run("Convert to Mask");

		// Otsuによるbinary画像の作成
		selectWindow("Otsu.tif");
		setAutoThreshold("Otsu");
		run("Convert to Mask");

		// 輪郭抽出(Find Edges)によるbinary画像の作成
		selectWindow("Edge.tif");
		run("Gaussian Blur...", "sigma=5"); // 前処理
		run("Find Edges");
		run("Subtract Background...", "rolling=50 sliding"); // ここでバックグラウンド減算をかける(なるべく幅の狭いEdgeを取得する)
		setAutoThreshold("IsoData dark");
		run("Convert to Mask");
		run("Analyze Particles...", "size=0.2-Infinity show=Masks exclude"); // 整形前に細かい粒子は除いておく
		for (j = 0; j < 5; j++) {
			run("Dilate");
		}
		run("Fill Holes"); // Cyst部分を埋める
		for (k = 0; k < 5; k++) {
			run("Erode");
		}

		// Otsuによるbinary画像と輪郭抽出によるbinary画像を組み合わせて、オルガノイド全体の領域を特定する
		imageCalculator("OR create", "Otsu.tif", "Mask of Edge.tif");

		selectWindow("Mask of Edge.tif");
		saveAs(".tif", fname + "_Edge.tif");

		selectWindow("Result of Otsu.tif");
		run("Median...", "radius=3"); //離れた位置にある細かい点はノイズと考えて除去する
		run("Fill Holes");
		run("Analyze Particles...", "size=30-Infinity show=Masks display exclude clear"); // 大きいオブジェクト(=オルガノイド)のみ残す
		saveAs(".tif", fname + "_Org.tif");

		if (isOpen("Results")) { // resultがなければスキップ
			selectWindow("Results");
			Table.sort("Area"); //オブジェクトを2個以上認識した場合に備えて、Areaで昇順にソートしておく
			saveAs("Results", fname + "_Org.csv");
			X = getResult("X", 0); // オルガノイドの幾何学的な重心の座標を取得(inch)
			Y = getResult("Y", 0);
			Minor = getResult("Minor", 0); // Fit ellipseした場合の副軸の長さを取得
			run("Close"); // 最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく
		}

		// Otsuによるbinary画像を用いて、まず辺縁部のCystを分節化する
		run("Create Selection");
		selectWindow("Otsu.tif");
		saveAs(".tif", fname + "_Otsu.tif"); // SelectWindowが済んでからrenameして保存
		run("Restore Selection");
		run("Clear Outside");
		run("Invert");
		run("Analyze Particles...", "size=0.05-30 circularity=0-1.00 show=Masks"); // 先に細かな粒子を除去する
		run("Fill Holes");
		run("Analyze Particles...", "size=0.05-30 circularity=0.1-1.00 show=Masks"); // 線状に分節化されてしまったオブジェクトは除去
		
		saveAs(".tif", fname + "_Peripheral.tif");
		rename("Peripheral.tif");

		// Minimumによるbinary画像を用いて、中心部のCystを分節化する
		selectWindow("Minimum.tif");
		alpha = 0.8; // 円のサイズを決定する定数
		Minor = (Minor / 20) * 1920; // inchをピクセル数に変換
		X = (X / 20) * 1920 - (Minor * alpha / 2); // 円が内接する正方形の左上の座標に変換する
		Y = (Y / 15) * 1440 - (Minor * alpha / 2);
		makeOval(X, Y, Minor * alpha, Minor * alpha);
		run("Clear Outside");
		run("Invert");
		run("Analyze Particles...", "size=0.05-30 circularity=0-1.00 show=Masks");
		run("Fill Holes");
		run("Analyze Particles...", "size=0.05-30 circularity=0.1-1.00 show=Masks");

		// 辺縁部のCystと中心部のCystを足した画像を作成する
		imageCalculator("OR create", "Minimum.tif", "Peripheral.tif");
		run("Analyze Particles...", "size=0.1-30 circularity=0-1.00 show=Masks display clear");
		saveAs(".tif", fname + "_Cyst.tif");

		selectWindow("Minimum.tif");
		saveAs(".tif", fname + "_Center.tif");
				
		if (isOpen("Results")) { // resultがなければスキップ
			selectWindow("Results");
			saveAs("Results", fname + "_Cyst.csv");
			run("Close"); // 最後に開いたまま残ってしまうので、resultのウィンドウを閉じておく
		}
		
		run("Close");
		run("Close All"); 
	}
}

run("Close All");