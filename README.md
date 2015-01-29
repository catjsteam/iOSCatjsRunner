iOS - Catjs Runner
=======================

This is iOS - XCode project - for Catjs Runner

**iOS - Catjs Runner** is a part of [catjs](https://github.com/catjsteam/catjs)

With this project you can run your catjs tests on iOS devices

We recommend you to start with our tutorials on :

[catjs tutorial video](https://www.youtube.com/watch?v=IlH_Y5dFEx8&list=PLNBO54hs1uMWJcL9y1RGZti2w9PEtUVVX) or [catjs jqm seed](https://github.com/ransnir/catjs-jqm-seed)

## Install

Import the project to XCode and run the application on your iOS device

## Setting the application with catjs

1. Setup you catjs project *[see tutorial](https://www.youtube.com/watch?v=IlH_Y5dFEx8&list=PLNBO54hs1uMWJcL9y1RGZti2w9PEtUVVX)*

2. Open the iOS - Catjs Runner from your device

3. Check that your catjs server and iOS are on the same WiFi and accessible.

4. Copy the **JSON POST path** that is written on the iOSCatjsRunner screen and add it to your catjsproject.json in the catjs project.<br />
Example for catproject.json the is config to run the test on iOS device:
		
		{
		    "name": "myproject",
		    "source": "src/",
		    "target": "target/",
		    "cattarget": "./",
		    "protocol": "http",
		    "analytics" : "Y",
		    "apppath": "./../app",
		    "runner": {
		        "run": {
		            "devices": [
		                {
		                    "type": "iphone",
		                    "disable" : false,
		                    "id": "all",
		                    "runner": {
		                        "name": "agent",
		                        "options" : { "ip" : "192.168.0.100", "port" : "54321", "path" : "/cat"}
		                    }
		                }
		            ]
		        },
		        "server": {
		            "host": "192.168.0.101",
		            "port": "8089"
		        }
		    },
		    "plugins": [

		    ],
		    "tasks": [

		    ]
		}

6. add scraps

<!--
            @[scrap
				@@name testDeviceInfoAndScreenshot
                @@embed true
                @@deviceinfo deviceinfo()
                @@screenshot screenshot()
			]@
    -->
	

5. Now if you feel ready open the command line from the cat-project and run the command:
		
		catcli -sr


Enjoy
catjsteam
