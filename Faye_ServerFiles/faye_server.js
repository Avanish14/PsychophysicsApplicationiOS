var http = require('http'),
    faye = require('faye');
	count = -1;

faye.Logging.logLevel = 'debug';

var bayeux = new faye.NodeAdapter({
  mount:    '/faye',
  timeout:  45
});

var server = http.createServer(function(request, response) {
  response.writeHead(200, {'Content-Type': 'text/plain'});
  response.write('Non-Bayeux request');
  response.end();
});

  serverLog = {
    incoming: function(message, callback) {
      if (message.channel === '/meta/subscribe') {
        logWithTimeStamp("Client Subscribed with ID: " + message.clientId);
      }
      if (message.channel.match(/\/users\/*/)) {
        logWithTimeStamp("User message on channel: " + message.channel);
      }
      return callback(message);
    }
  };
  logWithTimeStamp = function(logMessage) {
    var timestampedMessage;
    timestampedMessage = "" + (Date()) + " | " + logMessage;
    return console.log(timestampedMessage);
  };

function getcount() {
	return count;
};
  
bayeux.bind('handshake', function(client_id) {
  console.log("[handshake] - client: '"+ client_id +"'");
});

bayeux.bind('subscribe', function(client_id, channel) {
  count++;
  console.log("Client '"+ client_id +"' subscribed on channel: '"+ channel +"'");
  console.log("# of Clients subscribed to '" + channel + " ' is '" + count +" '.");
  });

bayeux.bind('unsubscribe', function(client_id, channel) {
  count--;
  console.log("Client '"+ client_id +"' unsubscribed on channel: '"+ channel +"'");
  console.log("# of Clients subscribed is " + count);
});

bayeux.bind('publish', function(client_id, channel, data) {
  console.log("Client '"+ client_id +"' published on channel: '"+ channel +"'");
  console.log("Message published:");
  console.log(data);
if (data["text"] == "start") {
  	console.log("in data(text) = start");
  	 fs = require('fs');
     fs.writeFile('clickerData.txt',"Experiment started on " +(Date()) +"\r\n", function (err) {
     	if (err)
     		return console.log('error writing to file clickerData.txt');
     	else {
     		return console.log("Experiment started on " +(Date()) +" > clickerData.txt");
     	}     
     });

  }
  if (data["text"] == "count") {
	fs = require('fs');
	fs.appendFile('clickerData.txt',"The number of connected users is "+count+"\r\n", function (err) {
		if (err)
			return console.log('error writing to file clickerData.txt');
		else {
			return console.log("The number of connected users is "+count+" > clickerData.txt");
		}
	});
  }
  var clientid;
  var answer;
  if (typeof data === 'string' || data instanceof String){
	  clientid = data.substring(0,data.indexOf(':'));
	  answer = parseInt(data.substring(data.indexOf(':')+1,data.length));
  } else {
	  clientid = Object.keys(data);
	  answer = parseInt(data[Object.keys(data)]);
  }
  if (!isNaN(answer)) {
  	 fs = require('fs');
     fs.appendFile('clickerData.txt',clientid+":"+answer+"\r\n", function (err) {
     	if (err)
     		return console.log('error writing to file clickerData.txt');
     	else {
     		return console.log(clientid+":"+answer+" > clickerData.txt");
     	}     
     });
  }
});
bayeux.bind('connect', function(client_id) {
  console.log("[connect] - client: '"+ client_id +"'");
});


bayeux.bind('disconnect', function(client_id) {
  console.log("Client: '"+ client_id +"' disconnected.");
});

bayeux.addExtension(serverLog);
bayeux.attach(server);


bayeux.getClient().subscribe('/psycho', function(message){
});

server.listen(5222);
console.log("Started Faye Server");