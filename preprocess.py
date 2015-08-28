# -*- coding: utf-8 -*-

import csv
from datetime import datetime
import os
import pprint
import sys

if len(sys.argv) < 3:
    print ("Usage: "+sys.argv[0]+" <inputfile> <startdate> <enddate>")
    print ("  e.g. "+sys.argv[0]+" yellow_tripdata_2015-06.csv \"2015-06-01 00:00:00\" \"2015-06-01 23:59:59\"")
    print ("  (all dates are inclusive)")
    sys.exit(1)

INPUT_FILE = sys.argv[1]
START_DATE = datetime.strptime(sys.argv[2], '%Y-%m-%d %H:%M:%S')
END_DATE = datetime.strptime(sys.argv[3], '%Y-%m-%d %H:%M:%S')
OUTPUT_FILE = 'visualization/data/rides.csv'
NYC_BOUNDS = [40.477399, -74.25909, 40.917577, -73.7000272] # Source: https://www.maptechnica.com/us-city-boundary-map/city/New%20York/state/NY/cityid/3651000?

rides = []

# Read files from file
with open(INPUT_FILE, 'rb') as f:
    r = csv.reader(f, delimiter=',')
    next(r, None) # remove header
    for VendorID, tpep_pickup_datetime, tpep_dropoff_datetime, passenger_count, trip_distance, pickup_longitude, pickup_latitude, RateCodeID, store_and_fwd_flag, dropoff_longitude, dropoff_latitude, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, total_amount in r:

        pickup_datetime = datetime.strptime(tpep_pickup_datetime, '%Y-%m-%d %H:%M:%S')
        dropoff_datetime = datetime.strptime(tpep_dropoff_datetime, '%Y-%m-%d %H:%M:%S')

        # Make sure dates are in range
        if pickup_datetime >= START_DATE and dropoff_datetime <= END_DATE:
            pickup_latitude = float(pickup_latitude)
            pickup_longitude = float(pickup_longitude)
            dropoff_latitude = float(dropoff_latitude)
            dropoff_longitude = float(dropoff_longitude)
            # Make sure lat/lng in nyc bounds
            if pickup_latitude > NYC_BOUNDS[0] and pickup_longitude > NYC_BOUNDS[1] and pickup_latitude < NYC_BOUNDS[2] and pickup_longitude < NYC_BOUNDS[3] and dropoff_latitude > NYC_BOUNDS[0] and dropoff_longitude > NYC_BOUNDS[1] and dropoff_latitude < NYC_BOUNDS[2] and dropoff_longitude < NYC_BOUNDS[3]:
                rides.append([pickup_latitude, pickup_longitude, dropoff_latitude, dropoff_longitude])

with open(OUTPUT_FILE, 'wb') as f:
    w = csv.writer(f)
    w.writerow(['lt0', 'ln0', 'lt1', 'ln1'])
    for r in rides:
        w.writerow(r)
    print('Successfully wrote '+str(len(rides))+' rides file: '+OUTPUT_FILE)

print ("Done.")
