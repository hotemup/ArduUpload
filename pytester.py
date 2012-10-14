import serial
import pymongo
from datetime import datetime
import calendar
import time
import random
lastTime = 0
def parseData(data,lastTime):
	timestamp = 1000*calendar.timegm(datetime.now().utctimetuple())
	data = "".join(str(x) for x in data if str(x).isalpha())
	if( timestamp - lastTime ) /1000 > 10:
		lastTime = timestamp
		lat = 40.48+ (random.random()/5-.2)
		lon = -74.440- (random.random()/5-.2)
		return [{"timestamp":timestamp , "user":data,"lat":lat,"lon":lon },lastTime]
	print "Bam,nice swipe "+data+"!"
	return [-1,lastTime]
dbConnection = pymongo.Connection("172.31.74.128",27017) #default port, change if ne

errors = ["block","thenticat","response","AAA","FF","ff"]
db = dbConnection.db1
brate = 115200
ser = serial.Serial('/dev/ttyACM0', brate)
while(1):
	temp = ser.readline()
	a = [x for x in errors if temp.find(x) != -1]
	if len(a) == 0:
		temp,lastTime = parseData(temp,lastTime)
		ser.flushInput()
		if temp != -1:
			print temp
			print "Bam,into the db"
			db.dataSet.save(temp)
