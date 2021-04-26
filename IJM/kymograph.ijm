// 変数 pxsize と tstep は、手入力で設定する
// pxsize は、オリジナルの画像と同じである必要がある
var pxsize = 0.069; // xyの大きさ、マイクロメートルで。
// tstep は、動画の時間をキモグラフの高さ（画素数）で割ったものである。
var tstep = 0.1; // 秒

// 線選択領域の開始点と終了点の座標を取得
getLine(x1, y1, x2, y2, lineWidth);
print("start ("+x1+" , "+y1+") - end ("+x2+" , "+y2+") ");

// 速度の計算
dx = abs(x2-x1);
dy = abs(y2-y1);
dx *= pxsize;
dy *= tstep;
velocity = dx/dy;
print(dx+" um in "+dy+" sec");
print("Velocity (um/s) = "+ d2s(velocity, 3));