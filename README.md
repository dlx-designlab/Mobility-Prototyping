# RIPPLE

All files are located in the `interactive-ripples` folder.  
The latest working version is usuing the LIDAR Sensor.
 
 How to Run:
 * Connect the lidar sensor with a USB cable.
 * Run the LIDAR Sensor Script: `sudo python3 lidar-scanner-osc.py`  
 this will start broadcasting lidar data ove OSC
 * Run the Processing script: 
    * option 1: via the terminal `processing-java --sketch=lidar_tracking_ripples --run`
    * option 2: open `lidar_tracking_ripples.pde` app in Processing and press Play
 * TIP: On the Demo PC in the Komaba Exhibition Room, you can quickly launch the demo via `bash ~/Desktop/RUN_RIPPLE.sh`
 
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

 
 # FireFlies Navigational Aid

All files are located in the `interactive-ripples` folder. The code for the Fireflies particle system is in fireflies_particles.pde
The latest working version is usuing the LIDAR Sensor. a mouse can be used for testing. 

Introduction
The FireFlies Navigational Aid is an interactive installation designed to guide users through a physical space using visual cues inspired by the behavior of fireflies. This project utilizes sensors and visual effects to create an immersive experience where virtual fireflies lead users to predetermined destinations. 

Features
* Interactive Guidance: Fireflies respond to user movements, guiding them towards specific destinations.
* Dynamic Visual Effects: The fireflies exhibit behaviors such as circling, approaching, natural flock movement and pulsing glows.
* Sensor Integration: Utilizes LiDAR sensors to track user positions in real-time.
* Customizable Destinations: Easily configure multiple destinations for the fireflies to guide users to.
* Nudge Mechanism: Fireflies can prompt users who are idle or off-path to resume movement.
* Configurable Parameters: Adjust settings like speed, glow intensity, and circling radius.

Controls

The Fireflies scenario can be accessed through the hot key 6 or from the GUI menu.

Mode Toggle:
* Press l to toggle live mode.
* Press f to show/hide the AOI frame.
* Press s to show/hide sensor data.
* Press u to show/hide the user circle.
* Press r to toggle between 60fps and 30fps.

Fireflies Behavior
States:

* Idle: Fireflies circle around a central point when no user is detected.
* Approach: Fireflies move towards the user when movement is detected.
* Circling: Fireflies circle around the user.
* Guiding: Fireflies lead the user towards the next destination.
* Nudge: If the user stops moving, fireflies prompt them to continue by circling aroung him and aligning in a straight line facing the destination.
