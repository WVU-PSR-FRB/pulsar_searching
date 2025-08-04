#! /bin/python/env

import numpy as np
import sys

# extract data from file.
datafile = (sys.argv)[1]

#This value can vary depending upone how many lines are there in *_ACCEL_0 file.If exceeded, may produce error.


### This block of code is used to automate the max # of rows to be read in *ACCEL* file
acce_file = open(datafile, 'r')
max_lines = 0
for line_number, line in enumerate(acce_file):
    if line.strip() == "":
        break
    max_lines += 1	
number_of_rows = max_lines - 3   # Subtract three because first three lines in "*ACCEL*" file do not contain data.
print("Number of lines read from *_ACCEL_0 file is: ", number_of_rows)
####


data = np.loadtxt(datafile, skiprows=3, max_rows = number_of_rows,  usecols=(0,1,2,4,6), dtype="str")
#print(data)

# now determine which birdies to include.
threshold = 50 
fout = open("GAIA.birds", "w")
fout.write("#Freq\t\t\t\twidth\t\t\t\tnharm\t\t\t\tgrow?\t\t\t\tbary?\n")

for current_row in range(number_of_rows):
	
    current_power = float(data[current_row, 2])
    current_nharm = data[current_row, 3]
    current_freq  = np.round(float(data[current_row, 4].split("(")[0]), 2)
	    
    if current_power > threshold:
        fout.write(f"{current_freq}\t\t\t\t0.01\t\t\t\t{current_nharm}\t\t\t\t0\t\t\t\t0\n")

fout.close()
