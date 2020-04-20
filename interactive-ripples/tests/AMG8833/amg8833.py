# -*- coding: utf-8 -*-

import time

import busio
import board

import adafruit_amg88xx

import matplotlib.pyplot as plt
import numpy as np

# Init I2C bus
i2c_bus = busio.I2C(board.SCL, board.SDA)

# Init Sensor
sensor = adafruit_amg88xx.AMG88XX(i2c_bus)

# wait for init Sensor
time.sleep(.1)

# setup 8x8 and bicubic
plt.subplots(figsize=(5,5))

# start loop
try:
    while True:
        # get sensor data
        sensordata = np.array(sensor.pixels)
        #for row in sensordata:
        #    print(["{0:.1f}".format(temp) for temp in row])
        #print("\n")
        
        #Mirror sensor data
        flip_h = sensordata[:, ::-1]
        #for row in flip_h:
        #    print(["{0:.1f}".format(temp) for temp in row])
        #print("\n")

        # show 8x8 data
        plt.subplot(1, 1, 1)
        fig = plt.imshow(flip_h, cmap="inferno")
        plt.colorbar()

        # show bicubic data
        #plt.subplot(1, 2, 2)
        #fig = plt.imshow(flip_h, cmap="inferno", interpolation="bicubic")
        #plt.colorbar()

        plt.pause(.01)
        plt.clf()
except KeyboardInterrupt:
    print("stop")
