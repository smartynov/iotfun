# NightLight

A smart LED stripe controller that keep track of time and motion around and behaves in intelligent way.

## Boot process & OTA

On boot ESP8266 connects to wifi and makes request to

1. Connect to wifi
2. Wait 0-5 seconds to get an IP
3. If no IP obtained in 5 seconds – go to step 7
4. Start telnet server (remote console)
5. TODO: Make request to http://iot.martynov.info/api/check?mac=MAC_ADDRESS&ip=LOCAL_IP&p=nightlight
6. TODO: Read response, if it contains "stop" – do nothing more
7. Run nightlight.lc
