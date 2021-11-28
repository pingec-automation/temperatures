#!/bin/bash

bt=$(timeout 15 gatttool -b A4:C1:38:25:A9:E4 --char-write-req --handle='0x0038' --value="0100" --listen | grep 'Notification handle' -m 1)
echo $bt

if [ -z "$bt" ]
then
	echo "The reading failed"
else
	#echo $bt
	hexa=$(echo $bt | awk '{print $6 " " $7 " " $8 " " $9 " " $10}')
	#echo $hexa


	temphexa=$(echo $bt | awk '{print $7$6}' | tr '[:lower:]' '[:upper:]')
	humhexa=$(echo $bt | awk '{print $8}' | tr '[:lower:]' '[:upper:]')
	batthexa=$(echo $bt | awk '{print $10$9}' | tr '[:lower:]' '[:upper:]')
	#echo temphexa=$temphexa humhexa=$humhexa batthexa=$batthexa
	temperature100=$(echo "ibase=16; $temphexa" | bc)
	humidity=$(echo "ibase=16; $humhexa" | bc)
	battery1000=$(echo "ibase=16; $batthexa" | bc)
	#echo temperature100=$temperature100 humidity=$humidity battery1000=$battery1000

	if [ $temperature100 -gt 32767 ]; then
		temperature100=$(($temperature100 – 65536))
	fi

	# Add missing leading zero if needed (sed): "-.05" -> "-0.05" and ".05" -> "0.05"
	temperature=$(echo "scale=2; $temperature100 / 100" | bc | sed 's:^\(-\?\)\.\(.*\)$:\10.\2:')


	battery=$(echo "scale=3; $battery1000 / 1000" | bc)
	timestamp=$(date --iso-8601=seconds)
	
	echo ts:$timestamp t:$temperature h:$humidity b:$battery hex:$hexa
	
	

fi