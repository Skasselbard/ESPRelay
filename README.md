Extend the loop.lua and the events.lua to add your program logic

Look at the deploy tools (python3) to get your scripts to the nodeMcu. There are scripts for configuration and remote command execution

You configure the nodeMcu manually by calling setSettings on the nodeMCU:
- ``setSetting("mqtt_name","yourMom")``
- ``setSetting("mqtt_server","10.0.5.4")``
- ``setSetting("mqtt_topic","#")``
- ``setSetting("wifi_ssid","NeighborsWlan")``
- ``setSetting("wifi_pwd","Password")``