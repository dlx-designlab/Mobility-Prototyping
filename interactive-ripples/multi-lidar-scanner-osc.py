from pyrplidar import PyRPlidar
from pythonosc import udp_client
import threading
from queue import Queue
import time
import numpy as np 
import socketio

sio = socketio.Client()

@sio.event
def connect():
    print('connection established')

@sio.event
def my_message(data):
    print('message received with ', data)
    sio.emit('my response', {'response': 'my response'})

@sio.event
def disconnect():
    print('disconnected from server')

class lidarReaderThread(threading.Thread):
    def __init__(self, sensor_port, stop_event):
        
        # init the thread
        threading.Thread.__init__(self)        
        
        self.stop_event = stop_event
        self.points = np.zeros(360)

        self.sensor_port = sensor_port
        self.lidar = PyRPlidar()
        self.lidar.connect(port=self.sensor_port, baudrate=115200, timeout=3)
        self.lidar.set_motor_pwm(500)    
        time.sleep(2)

    def run(self):
        
        # global client
        scan_generator = self.lidar.force_scan()
        print(f"LIDAR {self.sensor_port} is Scanning...")
        print("Press Ctrl-C to stop")
        
        osc_channel = f"lidar_{self.sensor_port[-1]}"

        for count, scan in enumerate(scan_generator()):
            scan_angle = round(scan.angle)
            if scan_angle < 360:
                self.points[round(scan.angle)] = scan.distance

                # print(self.points)            
                # print(self.sensor_port, count, scan)
                # print(sensor_port)
                # print(osc_channel)
                # client.send_message(osc_channel, [scan.angle, scan.distance, scan.start_flag])

            if self.stop_event.is_set():
                break


        print(f"Closing connetion to LIDAR sensor on {self.sensor_port}.")

        self.lidar.stop()
        self.lidar.set_motor_pwm(0)
        self.lidar.disconnect()


def lidar_scan():

    # event to stop the lidar threads 
    stop_event = threading.Event()

    lidar_01_thread  = lidarReaderThread("/dev/ttyUSB0", stop_event) #threading.Thread(target=lidarReaderThread, args=("/dev/ttyUSB0", stop_event, ))
    lidar_01_thread.start()

    lidar_02_thread  = lidarReaderThread("/dev/ttyUSB1", stop_event) #threading.Thread(target=lidarReaderThread, args=("/dev/ttyUSB1", stop_event, ))
    lidar_02_thread.start()

    # RPILIDAR Ports:
    # Linux   : "/dev/ttyUSB0"
    # MacOS   : "/dev/cu.SLAB_USBtoUART"
    # Windows : "COM5"
    try:
        while True:
            time.sleep(5)
    except (KeyboardInterrupt, SystemExit):
        # stop data collection.
        stop_event.set()    


if __name__ == "__main__":

    # setup OSC client
    # oscServerIP = "127.0.0.1"
    # oscServerPort = 12000
    # oscChannel = "/lidar"
    # client = udp_client.SimpleUDPClient(oscServerIP, oscServerPort)
    # print(f"OSC client broadcasting to {oscServerIP} port {oscServerPort} channel '{oscChannel}' ")
    
    # setup socket io client
    sio.connect('http://localhost:3000')
    sio.emit('weather', "snowyyyy")

    sio.wait()


    lidar_scan()
