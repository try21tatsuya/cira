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
	}
}

selectWindow("CH1.tif");
setAutoThreshold("Mean dark");
//setThreshold(20, 255);
setOption("BlackBackground", true);
run("Convert to Mask");
//setTool("rectangle");
makePolygon(602,718,794,568,956,568,957,717);
setBackgroundColor(0, 0, 0);
run("Clear", "slice");
saveAs(".tif", d + "CH1.tif");

run("Close All"); 
selectWindow("Log"); 
run("Close");

}