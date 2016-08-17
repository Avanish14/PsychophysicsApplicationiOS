var data1 = []
var data2 = []
var ids = []
var readFirstLine = false
var experimentDate = "experimentDate"

		
        //function readData() {
                var lineReader = require('readline').createInterface({
                         input: require('fs').createReadStream('clickerData.txt')
                });
                lineReader.on('line', function (line) {
                        if (readFirstLine == false) {
                                readFirstLine = true
                                experimentDate = line
                        }
                        if (line.indexOf(":")>-1 && line.indexOf(" ")<0) {
                        var id = line.substring(0,line.indexOf(":"));
                        if (ids.indexOf(id) < 0) {
                                ids.push(id);
                        }
                        data1.push(id);
                        data2.push(parseInt(line.substring(line.indexOf(":")+1,line.length)));
                }
        });
        lineReader.on('close', function(end) { writeData()} );
        //}

        function writeData() {
                /*var fs = require('fs');
                fs.writeFile("data.txt",experimentDate+"\n")
                fs.appendFile('data.txt',"\t\t")
                for (var x = 1; x <= 30; x++) {
                        fs.appendFile('data.txt',"\t"+x)
                }
                for (var x = 0; x<ids.length; x++) {
                        fs.appendFile('data.txt',"\n"+ids[x]+"\t\t");
                        for (var y = 1; y<=30; y++) {
                                if (data1.indexOf(ids[x])>-1) {
                                        fs.appendFile('data.txt',"\t"+data2[(data1.indexOf(ids[x]))])
                                        data1[data1.indexOf(ids[x])]=undefined;
                                }
                        }
                }*/
				var temp = "";
				temp += ("\t\t");
				for (var x = 1;x <= 30; x++){
					temp += ("\t"+x);
				}
				console.log(temp);
				for (var x = 0; x<ids.length; x++){
					temp = "";
					temp+= (ids[x]+"\t\t");
					for (var y=1; y<=30; y++){
						if (data1.indexOf(ids[x])>-1){
							temp+= ("\t"+data2[(data1.indexOf(ids[x]))]);
							data1[data1.indexOf(ids[x])]=undefined;
						}
					}
					console.log(temp);
				}
        }