from pyrplidar import PyRPlidar
import threading
from queue import Queue
import time
import socketio
import math
# import numpy as np 
# from pythonosc import udp_client


sio = socketio.Client()

# list of ports to which the lidar sensors are conneted
# RPILIDAR Ports:
# Linux   : "/dev/ttyUSB0"
# MacOS   : "/dev/cu.SLAB_USBtoUART"
# Windows : "COM5"
sensors_ports = ["/dev/ttyUSB0", "/dev/ttyUSB1"]
data_send_ferq = 0.5 #how often to send the data to the server (seconds)

# area of interes (actial screen size in mm) coordinates
margin = 850
scale = 30
aoe_coordinates = ((0,0),(1180,660))

class lidarReaderThread(threading.Thread):
    def __init__(self, sensor_port, pos_x, pos_y, pos_r, stop_event):
        
        # init the thread
        threading.Thread.__init__(self)        
        
        # an external interrupt event to stop the thread
        self.stop_event = stop_event
        
        # an arry to store all the lidar points
        self.points = [[0]*2 for i in range(360)] 

        #Lidar Postition'
        self.sensor_pos_x = pos_x
        self.sensor_pos_y = pos_y
        self.sensor_rotation = pos_r

        # inti LIDAR sensor
        self.sensor_port = sensor_port
        self.lidar = PyRPlidar()
        self.lidar.connect(port=self.sensor_port, baudrate=115200, timeout=3)
        self.lidar.set_motor_pwm(500)    
        time.sleep(2)

    def run(self):
        
        # global client
        global sio
        scan_generator = self.lidar.force_scan()
        print(f"LIDAR {self.sensor_port} is Scanning...")
        
        # osc_channel = f"lidar_{self.sensor_port[-1]}"

        for count, scan in enumerate(scan_generator()):
            scan_angle = round(scan.angle)
            if scan_angle < 360:
                new_point_x = self.sensor_pos_x + scan.distance * math.sin(math.radians(scan.angle + self.sensor_rotation))
                new_point_y = self.sensor_pos_y - scan.distance * math.cos(math.radians(scan.angle + self.sensor_rotation))
                self.points[scan_angle][0] = new_point_x
                self.points[scan_angle][1] = new_point_y              

                # print(self.points)
                # print(scan)            
                # print(self.sensor_port, count, scan)
            if self.stop_event.is_set():
                break


        print(f"Closing connetion to LIDAR sensor on {self.sensor_port}.")

        self.lidar.stop()
        self.lidar.set_motor_pwm(0)
        self.lidar.disconnect()


def lidar_scan():

    # event to stop the lidar threads 
    stop_event = threading.Event()
    
    # Init the LIDAR sensors scan
    # Each sensor needs a port, x,y position (mm) in the real world and rotation angle (degrees)
    lidar_01_thread  = lidarReaderThread(sensors_ports[0], 580, -350, 0, stop_event)
    lidar_01_thread.start()

    lidar_02_thread  = lidarReaderThread(sensors_ports[1], 580, +750, 180, stop_event)
    lidar_02_thread.start()
    
    print("All sensors scanning! Press Ctrl-C to stop")

    try:
        while True:
            time.sleep(data_send_ferq)

            # send LIDAR data to the socket
            # lidar_01_data = {"points": lidar_01_thread.points, "id": lidar_01_thread.sensor_port}
            lidar_01_data = {"points": [[(p[0]+margin)/scale, (p[1]+margin)/scale] for p in lidar_01_thread.points], "id": lidar_01_thread.sensor_port}
            sio.emit('updatelidar', lidar_01_data)

            lidar_02_data = {"points": [[(p[0]+margin)/scale, (p[1]+margin)/scale] for p in lidar_02_thread.points], "id": lidar_02_thread.sensor_port}
            sio.emit('updatelidar', lidar_02_data)

            # Calculate user position
            user_points = []
            for i in range(360):
                if (lidar_01_thread.points[i][0] > aoe_coordinates[0][0] and 
                    lidar_01_thread.points[i][1] > aoe_coordinates[0][1] and 
                    lidar_01_thread.points[i][0] < aoe_coordinates[1][0] and
                    lidar_01_thread.points[i][1] < aoe_coordinates[1][1] ):
                    
                    user_points.append(lidar_01_thread.points[i])
                    sio.emit("updatepassengerposition",{"id": 1,"position": {"x": (user_points[0][0] + margin) / scale, "y": (user_points[0][0]+margin) / scale }} )

                # if (lidar_01_thread.points[i][0] > (aoe_coordinates[0][0] + margin)/30 and 
                #     lidar_01_thread.points[i][1] > (aoe_coordinates[0][1] + margin)/30 and 
                #     lidar_01_thread.points[i][0] < (aoe_coordinates[1][0] + margin)/30 and
                #     lidar_01_thread.points[i][1] < (aoe_coordinates[1][1] + margin)/30 ):


            # print(user_points)
         
    except (KeyboardInterrupt, SystemExit):
        # stop data collection.
        stop_event.set()    


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


if __name__ == "__main__":

    # setup OSC client
    # oscServerIP = "127.0.0.1"
    # oscServerPort = 12000
    # oscChannel = "/lidar"
    # client = udp_client.SimpleUDPClient(oscServerIP, oscServerPort)
    # print(f"OSC client broadcasting to {oscServerIP} port {oscServerPort} channel '{oscChannel}' ")
    
    # setup socket io client
    sio.connect('http://localhost:3000')
    sio.emit('weather', "Snowwwyyy")
    # sio.wait()

    lidar_scan()
