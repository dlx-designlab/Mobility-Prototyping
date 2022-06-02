from pyrplidar import PyRPlidar
import threading
from queue import Queue
import time
import socketio
import math
from statistics import mean
import numpy as np 

# list of ports to which the lidar sensors are conneted
# RPILIDAR Ports:
# Linux   : "/dev/ttyUSB0"
# MacOS   : "/dev/cu.SLAB_USBtoUART"
# Windows : "COM5"

# Each sensor needs a port, x,y position (mm) in the real world and rotation angle (degrees)
sensors_config = [
    {
        "port": "/dev/ttyUSB0",
        "x": 580,
        "y": -220,
        "a": 180
    },
    {  
        "port": "/dev/ttyUSB1",
        "x": 1185,
        "y": 750,
        "a": 0
    },
    {   
        "port": "/dev/ttyUSB2",
        "x": 0,
        "y": 750,
        "a": 0
    }    
]

# area of interes (actual screen/step-area size in mm) coordinates
aoi_coordinates = ((0,0),(1180,660))

sio = socketio.Client()
data_send_ferq = 0.2 #how often to send the data to the server (seconds)

# the scale is to convert real world dimentions to screen Pixels
# to determine the scaling, set the margin to 0
# place an object at the bottom right corner of the screen
# in the front-end click in the center of the detected object
# devide the "X" coordinate by 100 and miltiply by the current scale 
scale = 11.7

# use this in combinaion with scale to show objects which would usually appear off screen
margin = 0


class lidarReaderThread(threading.Thread):
    def __init__(self, sensor_port, pos_x, pos_y, pos_r, stop_event):
        
        # init the thread
        threading.Thread.__init__(self)        
        
        # an external interrupt event to stop the thread
        self.stop_event = stop_event
        
        # an arry to store all the lidar points
        self.points = [[0]*2 for i in range(360)] 

        #Lidar Postition
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
        
        global sio
        scan_generator = self.lidar.force_scan()
        print(f"LIDAR {self.sensor_port} is Scanning...")

        last_angle = 0
        for count, scan in enumerate(scan_generator()):
            scan_angle = round(scan.angle)
            if scan_angle < 360:
                new_point_x = self.sensor_pos_x + scan.distance * math.sin(math.radians(scan.angle + self.sensor_rotation))
                new_point_y = self.sensor_pos_y - scan.distance * math.cos(math.radians(scan.angle + self.sensor_rotation))
                self.points[scan_angle][0] = new_point_x
                self.points[scan_angle][1] = new_point_y
            
            # check for skipped scan angles an reset clear the array data for those angles.
            # skipped_angles = scan_angle - last_angle
            # if skipped_angles > 1:
            #     # print(f" {skipped_angles} ")
            #     for i in range(skipped_angles):
            #         if last_angle + i +1 < 360:
            #             self.points[last_angle+i+1][0] = self.sensor_pos_x
            #             self.points[last_angle+i+1][1] = self.sensor_pos_y

            last_angle = scan_angle

            # print(self.points)
            # print(scan)            
            # print(self.sensor_port, count, scan)

            if self.stop_event.is_set():
                break


        print(f"Closing connetion to LIDAR sensor on {self.sensor_port}.")

        self.lidar.stop()
        self.lidar.set_motor_pwm(0)
        self.lidar.disconnect()


def lidar_scanner():

    # event to stop the lidar threads 
    stop_event = threading.Event()
    
    # Init the LIDAR sensors scan
    lidar_sensors_threads = []
    for sensor in sensors_config:        
        new_thread  = lidarReaderThread(sensor["port"], sensor["x"], sensor["y"], sensor["a"], stop_event)
        lidar_sensors_threads.append(new_thread)
        lidar_sensors_threads[-1].start()
    
    print("All sensors scanning! Press Ctrl-C to stop")

    try:
        while True:
            time.sleep(data_send_ferq)

            # send LIDAR data to the socket
            for sensor_thread in lidar_sensors_threads:
                sensor_data = {"points": [[(p[0]+margin)/scale, (p[1]+margin)/scale] for p in sensor_thread.points], "id": sensor_thread.sensor_port}
                sio.emit('updatelidar', sensor_data)

            # Calculate user positions and send to socket
            user_points = []
            for sensor_thread in lidar_sensors_threads:
                for i in range(360):
                    if (sensor_thread.points[i][0] > aoi_coordinates[0][0] and 
                        sensor_thread.points[i][1] > aoi_coordinates[0][1] and 
                        sensor_thread.points[i][0] < aoi_coordinates[1][0] and
                        sensor_thread.points[i][1] < aoi_coordinates[1][1] ):
                        
                        user_points.append(sensor_thread.points[i])

                if len(user_points) > 4:
                    x_points = np.array([p[0] for p in user_points])
                    y_points = np.array([p[1] for p in user_points])                                            
                    
                    # get user position                    
                    avg_x = np.mean(x_points) #mean([p[0] for p in user_points])
                    avg_y = np.mean(y_points) #mean([p[1] for p in user_points])

                    # get user orientation
                    user_angle = math.atan(np.polyfit(x_points, y_points, 1)[0])
                    # print(math.degrees(user_angle))

                    sio.emit("updatepassengerposition",{"id": 1,"position": {"x": (avg_x + margin) / scale, "y": (avg_y + margin) / scale, "rotation": user_angle }} )


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
    # todo: disconnect lidar sensors : set thread event > stop_event.set()
    print('disconnected from server')



if __name__ == "__main__":
    
    # setup socket io client
    sio.connect('http://localhost:3000')
    sio.emit("updatepassengerposition",{"id": 1,"position": {"x": 0, "y": 0}} )    
    # sio.wait()

    lidar_scanner()