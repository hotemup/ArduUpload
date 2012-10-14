mport serial
import pymongo
from datetime import datetime

def parseData(data):
	data = "".join(str(x) for x in data if str(x).isalpha())
	return {"time":str(datetime.now())*1000 , "user":data,"lat":40.4848,"lon":-744367 }

dbConnection = pymongo.Connection("172.31.76.213",27017) #default port, change if needed
db = dbConnection.test   
brate = 9600
ser = serial.Serial('COM3', brate)
while(1):
	temp = ser.readline()
	temp = temp.strip()
	db.dataSet.save({'d':'d'})
	print temp
