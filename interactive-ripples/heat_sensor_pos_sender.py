# -*- coding: utf-8 -*-
import time

import busio
import board

import adafruit_amg88xx

import matplotlib.pyplot as plt
import numpy as np

import argparse

#from pythonosc import osc_message_builder
from pythonosc import udp_client
from pythonosc.osc_message_builder import OscMessageBuilder

i2c_bus = busio.I2C(board.SCL, board.SDA)
sensor = adafruit_amg88xx.AMG88XX(i2c_bus)
time.sleep(.1)
plt.subplots(figsize=(5,5))

IP = '127.0.1.1'
port = 5005

basetemp = 20.0

client = udp_client.UDPClient(IP, port)

print("ip:" + str(IP) + ", Port: " + str(port))


def main():
    #print("\n" + "get sensor data")
    sensordata = np.array(sensor.pixels)
    sensordata = sensordata[:, ::-1]
    #for row in sensordata:
    #    print (["{0:.1f}".format(temp) for temp in row])
    
    print("\n")
    print(sensordata.max())
    
    if sensordata.max() > basetemp:
        #pos =list(zip(*np.where(sensordata > sensordata.max() * 0.95)))
        pos =list(zip(*np.where(sensordata == sensordata.max())))
        print(pos)
        msg = OscMessageBuilder(address="/pos")
        for i in pos:
            msg = OscMessageBuilder(address="/pos")
            x, y = i
            msg.add_arg(int(x))
            msg.add_arg(int(y))
            m = msg.build()
            print(m.address, m.params)
            client.send(m)

            time.sleep(0.05)
    else:
        print("nobody is here")

if __name__ == "__main__":
    try:
        while True:
            main()
    except KeyboardInterrupt:
        print("stop");
