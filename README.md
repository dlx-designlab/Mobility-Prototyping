# RIPPLE

All files are located in the `interactive-ripples` folder.  
The latest working version is usuing the LIDAR Sensor.
 
 How to Run:
 * Connect the lidar sensor with a USB cable.
 * Run the LIDAR Sensor Script: `sudo python3 lidar-scanner-osc.py`  
 this will start broadcasting lidar data ove OSC
 * Open `lidar_tracking_ripples.pde` app in Processing and press Play
 
 Callibrating Area of Interest (AOI):
 * Place an object in each corner of the screen top left and bottom right (top is closer to the sensor).  
   Small round objects such as bottles work best. 
 * Run the `lidar_tracking_ripples.pde` app as described above
 * Disable "LIVE MODE" (from the control panel in the top left corner)
 * Find te objects detected in the app (you will see only the sides visible to the sensor)
 * Click at center of each object
 * The "mouse-click" coordinates will be printed to the console (if running in full screen mode you will need to close the app to see the output)
 * Update the `tlCorner` and `brCorner` variables in `idar_tracking_ripples.pde` code 
 * Run the app again
 * Check the AOI (red frame) corresponds to the physical screen edges

 
