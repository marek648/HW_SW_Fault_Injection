#!/usr/bin/python3
#Reset PC by raspberry PI 4.0 when PC freezes
#Author: Marek Lörinc
#Date: 08.05.2022

import RPi.GPIO as GPIO
from time import sleep
import sys
import os

RESET_PIN = 3	#GPIO PIN RPI connected to PC 
if len(sys.argv) != 2:
	sys.exit("Enter 1 argument (hostname)")

hostname = str(sys.argv[1])	#PC IP Address got from argument


if (__name__== "__main__"):
	#Configuration of GPIO pin - set as output
	GPIO.setmode(GPIO.BCM)
	GPIO.setwarnings(False)
	GPIO.setup(RESET_PIN, GPIO.OUT)
	GPIO.output(RESET_PIN, GPIO.LOW)
	
	while True:
		#Send ping command
		response = os.system("ping -c 1 " + hostname)
		#If PC doesn't respond, send logical 1 to GPIO reset pin for 7 seconds
		if response != 0:
			print("restart button signal sent")
			GPIO.output(RESET_PIN, GPIO.HIGH)
			sleep(7)
			GPIO.output(RESET_PIN, GPIO.LOW)
			sleep(70)	#Wait for PC connection to network after restart
		sleep(10) 