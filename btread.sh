#!/bin/bash

read_values(){
	device_mac=$1
	bt=$(timeout 15 gatttool -b $device_mac --char-write-req --handle='0x0038' --value="0100" --listen | grep 'Notification handle' -m 1)
	echo $bt

	if [ -z "$bt" ]
	then
		echo "The reading failed"
	else
		hexa=$(echo $bt | awk '{print $6 " " $7 " " $8 " " $9 " " $10}')
		temphexa=$(echo $bt | awk '{print $7$6}' | tr '[:lower:]' '[:upper:]')
		humhexa=$(echo $bt | awk '{print $8}' | tr '[:lower:]' '[:upper:]')
		batthexa=$(echo $bt | awk '{print $10$9}' | tr '[:lower:]' '[:upper:]')

		temperature100=$(echo "ibase=16; $temphexa" | bc)
		humidity=$(echo "ibase=16; $humhexa" | bc)
		battery1000=$(echo "ibase=16; $batthexa" | bc)
		
		if [ $temperature100 -gt 32767 ]; then
			temperature100=$(echo "$temperature100 - 65536" | bc)
		fi

		# Add missing leading zero if needed (sed): "-.05" -> "-0.05" and ".05" -> "0.05"
		temperature=$(echo "scale=2; $temperature100 / 100" | bc | sed 's:^\(-\?\)\.\(.*\)$:\10.\2:')

		battery=$(echo "scale=3; $battery1000 / 1000" | bc)
		timestamp=$(date --iso-8601=seconds)
		
		echo ts:$timestamp t:$temperature h:$humidity b:$battery >> "${device_mac}.log"
		# Trim to 24*15*2 = 720 lines
		echo ts:$timestamp t:$temperature h:$humidity b:$battery >> "${device_mac}.trim.log"
		echo "$(tail -720 ${device_mac}.trim.log)" > "${device_mac}.trim.log"
		
	fi
}

sudo hciconfig hci0 down
sleep 1
sudo hciconfig hci0 up

for DEVICE in $(cat monitored.txt)
do
	read_values "$DEVICE"
done
