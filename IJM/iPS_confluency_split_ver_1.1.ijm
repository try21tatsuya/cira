d = getDirectory("Choose a Directory");

files = getFileList(d);
for (i = 0; i < files.length; i++) {
	f = d + files[i];
	if (!File.isDirectory(f)) {
		open(files[i]);
		run("Duplicate...", " ");
		run("Duplicate...", " ");
		run("Duplicate...", " ");
		run("Duplicate...", " ");
		run("Duplicate...", " ");
		run("Duplicate...", " ");
		run("Duplicate...", " ");
		run("Duplicate...", " ");
		makeRectangle(0, 0, 320, 240);
		run("Crop");
		saveAs(".tif", d + File.separator + "out" + File.separator + files[i] + "_crop_1_.tif");
		run("Close");
		makeRectangle(320, 0, 320, 240);
		run("Crop");
		saveAs(".tif", d + File.separator + "out" + File.separator + files[i] + "_crop_2_.tif");
		run("Close");
		makeRectangle(640, 0, 320, 240);
		run("Crop");
		saveAs(".tif", d + File.separator + "out" + File.separator + files[i] + "_crop_3_.tif");
		run("Close");
		makeRectangle(0, 240, 320, 240);
		run("Crop");
		saveAs(".tif", d + File.separator + "out" + File.separator + files[i] + "_crop_4_.tif");
		run("Close");
		makeRectangle(320, 240, 320, 240);
		run("Crop");
		saveAs(".tif", d + File.separator + "out" + File.separator + files[i] + "_crop_5_.tif");
		run("Close");
		makeRectangle(640, 240, 320, 240);
		run("Crop");
		saveAs(".tif", d + File.separator + "out" + File.separator + files[i] + "_crop_6_.tif");
		run("Close");
		makeRectangle(0, 480, 320, 240);
		run("Crop");
		saveAs(".tif", d + File.separator + "out" + File.separator + files[i] + "_crop_7_.tif");
		run("Close");
		makeRectangle(320, 480, 320, 240);
		run("Crop");
		saveAs(".tif", d + File.separator + "out" + File.separator + files[i] + "_crop_8_.tif");
		run("Close");
		makeRectangle(640, 480, 320, 240);
		run("Crop");
		saveAs(".tif", d + File.separator + "out" + File.separator + files[i] + "_crop_9_.tif");
		run("Close");
	}
}