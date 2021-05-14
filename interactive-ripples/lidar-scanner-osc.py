from pyrplidar import PyRPlidar
from pythonosc import udp_client
import time

def simple_scan():

    oscServerIP = "127.0.0.1"
    oscServerPort = 12000
    oscChannel = "/lidar"

    client = udp_client.SimpleUDPClient(oscServerIP, oscServerPort)
    print(f"OSC client broadcasting to {oscServerIP} port {oscServerPort} channel '{oscChannel}' ")

    lidar = PyRPlidar()
    lidar.connect(port="/dev/ttyUSB0", baudrate=115200, timeout=3)
    # Linux   : "/dev/ttyUSB0"
    # MacOS   : "/dev/cu.SLAB_USBtoUART"
    # Windows : "COM5"
                  
    lidar.set_motor_pwm(500)
    time.sleep(2)
    
    scan_generator = lidar.force_scan()
    print("LIDAR is Scanning...")
    print("Press Ctrl-C to stop")
    try:
        for count, scan in enumerate(scan_generator()):
            # print(count, scan)
            client.send_message(oscChannel, [scan.angle, scan.distance, scan.start_flag])

    except KeyboardInterrupt:
        print("Closing connetion to LIDAR sensor.")
        pass

    lidar.stop()
    lidar.set_motor_pwm(0)
    lidar.disconnect()

if __name__ == "__main__":
    simple_scan()