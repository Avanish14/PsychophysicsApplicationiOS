# PsychophysicsApplicationiOS

An iOS application to be used for a psychophysics study at WINLAB. 
More details about the project and study can be found at [http://sites.google.com/site/psychophysicsapp.](http://sites.google.com/site/psychophysicsapp)

# Running the application

To edit and build the application, download the project and open Psycho.xcworkspace in Xcode. 

# Running the server

Before running the server, install the packages by running the following command: 
```javascript
npm install
```
Run faye_server.js to start the server. To publish any messages to the channel, run faye_publish.js and the message afterwards. 
Example: 
```javascript
node faye_publish.js start
```
Running this line will publish "start" to the channel.

# References 

* [Faye](https://github.com/faye/faye) - server that PsychophysicsApplicationiOS connects to
* [FayeSwift](https://github.com/hamin/FayeSwift) - client that PsychophysicsApplicationiOS implements

# License

This project is licensed under the MIT License.
