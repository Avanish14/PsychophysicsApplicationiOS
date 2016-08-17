var faye = require('faye'),
    client = new faye.Client('http://localhost:5222/faye');


faye.Logging.logLevel = 'debug';

if (process.argv.length <= 2) {
    client.publish("/cool", {"text": "no argument"});
}

var publication = client.publish("/psycho", {"text": process.argv[2]});

/*if (process.argv[2] == "count"){
	var millisecondsToWait = 500;
	setTimeout(function() {
		// Whatever you want to do after the wait
	}, millisecondsToWait);
	//var count = 
	//console.log("The number of connected users to "+channel+" is "+count);
}*/

publication.callback(function() {
	//console.log("Sent Message: {text:start} on channel: /psycho");
	process.exit(0)
});
publication.errback(function(error) {
    //console.log("FAILED TO PUBLISH: {text:start}", error);
});