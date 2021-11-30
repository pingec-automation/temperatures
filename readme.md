1. Scan devices with ```sudo hcitool lescann```
1. Find MAC of thermometer eg. A4:C1:38:25:A9:E4 LYWSD03MMC
1. Replace MAC in btread.sh with scanned value
1. Setup git username and email, set it to store password to disk with ```git config --global credential.helper store```
1. Run ```bash btread.sh && bash gitpush.sh```, github will require Personal access token to be input as the password, then it will be stored on disk
1. Add to crontab: ```*/30 * * * * cd /home/pi/temperatures/ && bash btread.sh && bash gitpush.sh```
