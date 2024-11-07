class FirefliesParticleSystem{
  ArrayList<Firefly> fireflies = new ArrayList<Firefly>();
  ArrayList<PVector> destinations = new ArrayList<PVector>();
  int currentDestinationIndex = 0;

  PVector userPos;
  PVector userLastPosition;
  Integer guidingStartTime = null;
  Integer userLastMovedTime = null;
  Integer lastNudgeTime = null;
  int nudgeCooldown = 30000;
  int nudgeDelay = 5000;
  Integer destinationStayStartTime = null;
  boolean isDestinationInitiated = false;
  int requiredStayDuration = 1000; // The required Time To stay in the destination to initiate and move to another
  int distanceFromDestination = 150; // The distance of the user from the destination that is required to initiate the destination

  // Constructor
  FirefliesParticleSystem(){

    // Initialize points of destination
    destinations.add(new PVector(155,923)); // First destination
    destinations.add(new PVector(1800,923)); // Second destination
    destinations.add(new PVector(909, 897)); // Third destination


    // Initialize fireflies
    for (int i = 0; i < 5; i++) {
      fireflies.add(new Firefly(destinations.get(0) , i));
    }

    // Initialize userLastPosition to center of canvas
    userLastPosition = new PVector(width / 2, height / 2);
 }

    void initiateNudge() {
        for (Firefly firefly : fireflies) {
            firefly.state = "nudge_circling";
            firefly.cumulativeAngle = 0;
            firefly.angle = random(TWO_PI);

            // Randomize circle radius and angular speed for nudge circling
            firefly.circleRadius = random(40, 60);
            firefly.angularSpeed = random(0.05f, 0.1f);
        }
        lastNudgeTime = millis(); // Record the time of this nudge
        println("Nudge initiated at: " + lastNudgeTime); 
    }

  void run () {
    trackUserMovement();
    drawDestination();
    handleDestinationInitiation();

  boolean userInsideCanvas = isUserInsideCanvas();

    // Reset fireflies to idle state if user is outside the canvas
    if (!isUserInsideCanvas()) {
      for (Firefly firefly : fireflies) {
        if (!firefly.state.equals("idle")) {
          firefly.state = "idle";
        }
      }
    } else {
        // Transition fireflies from idle to approach when user is inside canvas
        for (Firefly firefly : fireflies) {
            if (firefly.state.equals("idle")) {
                firefly.state = "approach";
            }
        }
    }

    // Update and display fireflies
    for (Firefly firefly : fireflies) {
      firefly.update(destinations.get(currentDestinationIndex), userPos, userInsideCanvas );

   // Handle state transitions that depend on guidingStartTime
        if (firefly.state.equals("circling") && firefly.cumulativeAngle >= 2 * TWO_PI) {
            firefly.state = "guiding";
            println("Firefly " + firefly.index + " entered guiding state");
            if (guidingStartTime == null) {
                guidingStartTime = millis(); // Start guiding timer
                println("guidingStartTime set to " + guidingStartTime);
            }
            if (userLastMovedTime == null) {
                userLastMovedTime = millis(); // Initialize last moved time
                println("userLastMovedTime set to " + userLastMovedTime);
            }
        }

        // Handle nudge alignment transition
        if (firefly.state.equals("nudge_circling") && firefly.cumulativeAngle >= 2 * TWO_PI) {
            firefly.state = "nudge_aligning";
        }

        // Return to guiding state if user starts moving
        if (firefly.state.equals("nudge_aligning")) {
            int currentTime = millis();
            if (userLastMovedTime != null && currentTime - userLastMovedTime < 500) {
                firefly.state = "guiding";
            }
        }

      firefly.display();
    }
    // Check for nudge conditions globally
    if (shouldNudge()) {
        initiateNudge();
    }

  }

  // Draw destinations
  void drawDestination(){
    for (int i = 0; i < destinations.size(); i++) {
      if (i == currentDestinationIndex) {
        // Highlight the current destination
        fill(0, 250, 0);
      } else {
        fill(250, 0, 0);
      }
      noStroke();
      ellipse(destinations.get(i).x, destinations.get(i).y, 15, 15);
    }
  }


  // Handle destination initiation logic
  void handleDestinationInitiation() {
    // userPos = getUserPosition();
    PVector currentDestination = destinations.get(currentDestinationIndex);

    // Check if user is near the current destination
    if (userPos.dist(currentDestination) < distanceFromDestination && isUserInsideCanvas()) {
      if (destinationStayStartTime == null) {
        destinationStayStartTime = millis();
      } else if (millis() - destinationStayStartTime >= requiredStayDuration) {
        // User has stayed long enough
        isDestinationInitiated = true;
        currentDestinationIndex++;
        destinationStayStartTime = null;

        // Check if all destinations are completed
        if (currentDestinationIndex >= destinations.size()) {
          // Task is complete
          
          fill(255);
          textSize(32);
          textAlign(CENTER, CENTER);
          text("Toda", width / 2, height / 2);
          currentDestinationIndex= 0 ;

        } else {
          // Reset fireflies to guide to the next destination
          for (Firefly firefly : fireflies) {
            firefly.state = "guiding";
          }
          isDestinationInitiated = false;
        }
      }
    } else {
      destinationStayStartTime = null;
    }
  }

  // Update user movement tracking
  void trackUserMovement() {
    // If user is outside canvas, do not update userLastMovedTime
    if (!isUserInsideCanvas()) {
      return;
    }

    // PVector userPos = getUserPosition();
    if (userPos.dist(userLastPosition) > 150) {
      userLastMovedTime = millis(); // Update last moved time
      println("userLastMovedTime updated to " + userLastMovedTime);
    }
    userLastPosition = userPos.copy();
  }

  boolean shouldNudge() {
    int currentTime = millis();

    // Ensure that guiding has started
    if (guidingStartTime == null) {
      println("shouldNudge: guidingStartTime is null");
      return false; // Do not nudge if guiding has not started
    }

    // Ensure that a minimum time has passed since guiding started
    if (currentTime - guidingStartTime < nudgeDelay) {
      println("shouldNudge: nudgeDelay not passed yet");
      return false; // Don't nudge yet
    }

    // Check if cooldown has passed
    if (lastNudgeTime != null && currentTime - lastNudgeTime < nudgeCooldown) {
      println("shouldNudge: nudgeCooldown not passed yet");
      return false;
    }

    // Check if user hasn't moved for more than 5 seconds
    if (userLastMovedTime != null && currentTime - userLastMovedTime > 5000) {
      println("shouldNudge: user hasn't moved for more than 5 seconds");
      return true;
    }

    // Check if it's been more than 10 seconds since guiding started
    if (currentTime - guidingStartTime > 10000) {
      println("shouldNudge: more than 10 seconds since guiding started");
      return true;
    }
    println("shouldNudge: no conditions met");
    return false;
  }

}

///////////////////////////////////////////////////////

//Firefly Class
class Firefly {
  PVector position;
  PVector velocity;
  PVector desiredVelocity; // Property for easing
  PVector userPos; 
  float maxSpeed;
  float angle;
  int index;
  int maxDistanceFromUser; 

  // Glow properties
  float glowIntensity;
  float glowDirection;

  // Circling properties
  float circleRadius;
  float angularSpeed;
  float cumulativeAngle;

  // State variable
  String state; // 'idle', 'approach', 'circling', 'guiding', 'nudge_circling', 'nudge_aligning', 'circling_destination'

  Firefly(PVector destination, int index) {
    this.position = destination.copy(); // Start at the first destination point
    this.velocity = PVector.random2D();
    this.desiredVelocity = this.velocity.copy(); // Initialize desiredVelocity
    this.angle = random(TWO_PI);
    this.index = index; // Assign the index
    
    

    // FireFlies Controls
    this.maxSpeed = 3.5; // Controls the max speed of the fireflies (it also affects the distance in which they spread) 
    this.maxDistanceFromUser = 350; // Controls the maximum distance the Fireflies will get away from the user (pixels)

    // Initialize glow intensity and pulsing speed
    this.glowIntensity = random(100, 255);
    this.glowDirection = random(0.5f, 1.5f);

    // For circling behavior
    this.circleRadius = random(120, 250);
    this.angularSpeed = random(0.02f, 0.1f);
    this.cumulativeAngle = 0; 
    
    // State variable
    this.state = "idle";
  }

  void update(PVector currentDestination, PVector parentUserPos, boolean userInsideCanvas) {
    this.userPos = parentUserPos.copy();

    
    if (!isUserInsideCanvas()) {
      // Return to idle state and circle around the center
      if (!this.state.equals("idle")) {
        this.state = "idle";
      }
      this.circleAroundPoint(new PVector(width / 2, height / 2));
    } else if (this.state.equals("idle")) {
      this.circleAroundPoint(new PVector(width / 2, height / 2));
    } else if (this.state.equals("approach")) {
      // Firefly moves toward the user at a fast pace
      this.approachUser();
    } else if (this.state.equals("circling")) {
      // Circling behavior around the user
      this.circleAroundUser();


    } else if (this.state.equals("guiding")) {
      // If user is near the current destination, switch to circling_destination
        float fireflyDistanceToDestination = this.position.dist(currentDestination);
        if (fireflyDistanceToDestination < 100) {
        this.state = "circling_destination";
        this.angle = random(TWO_PI);
        this.cumulativeAngle = 0;
        this.circleRadius = random(100, 150);
        this.angularSpeed = random(0.05f, 0.1f);
      } else {
        this.guideUser(currentDestination);
      }
    } else if (this.state.equals("circling_destination")) {
      // Circling around the current destination
      this.circleAroundDestination(currentDestination);

       // Switch back to guiding if user moves away from the destination
      float userDistanceToDestination = this.userPos.dist(currentDestination);
      if (userDistanceToDestination > 50) { // Adjust threshold as needed
      this.state = "guiding";
      }
    } else if (this.state.equals("nudge_circling")) {
      // Nudge circling around the user
      this.circleAroundUser();

      // Transition to nudge aligning after 2 rotations
      if (this.cumulativeAngle >= 2 * TWO_PI) {
        this.state = "nudge_aligning";
      }
    } else if (this.state.equals("nudge_aligning")) {
      // Align in a straight line pointing toward the current destination
      this.alignTowardDestination(currentDestination);

    }

    // Update velocity and position
    if (this.state.equals("circling") || this.state.equals("circling_destination") || this.state.equals("nudge_circling")) {
    // In circling states, set velocity directly
    this.velocity = this.desiredVelocity.copy();
    } else {
    // Easing factor (adjust between 0 and 1 for smoothness)
    float easing = 0.1f; // Adjust as needed

    // Update velocity with easing
    this.velocity.lerp(this.desiredVelocity, easing);
    }

    // Update position with the velocity
    this.position.add(this.velocity);

    // Update glow intensity for pulsing effect
    if (!this.state.equals("nudge_circling") && !this.state.equals("nudge_aligning")) {
      this.glowIntensity += this.glowDirection * 7; // Increased multiplier
      if (this.glowIntensity > 255 || this.glowIntensity < 100) {
        this.glowDirection *= -1; // Reverse pulsing direction
      }
    }
  }

  void display() {
    // Outer glow with pulsing effect
    noStroke();
    fill(255, 255, 0, this.glowIntensity / 2); // Adjust alpha based on glowIntensity
    ellipse(this.position.x, this.position.y, 25, 25);

    // Firefly core
    fill(255, 255, 0);
    ellipse(this.position.x, this.position.y, 5, 5); // Reduced core size
  }

  void circleAroundPoint(PVector point) {
    this.angle += this.angularSpeed;
    PVector offset = new PVector(cos(this.angle), sin(this.angle)).mult(this.circleRadius);
    PVector target = PVector.add(point, offset);

    PVector toTarget = PVector.sub(target, this.position);
    toTarget.setMag(this.maxSpeed);
    this.desiredVelocity = toTarget;
  }

  void approachUser() {
    // PVector userPos = getUserPosition();

    PVector toUser = PVector.sub(this.userPos, this.position);
    toUser.setMag(5);
    this.desiredVelocity = toUser;

    // Check if close enough to user to start circling
    float distanceToUser = PVector.dist(this.position, this.userPos);
    if (distanceToUser < 10) {
      // Reset variables for circling
      this.angle = random(TWO_PI);
      this.cumulativeAngle = 0;
      this.circleRadius = random(120, 250);
      this.angularSpeed = random(0.05f, 0.1f);
      this.state = "circling";
    }
  }

  void circleAroundUser() {
    this.angle += this.angularSpeed;
    this.cumulativeAngle += this.angularSpeed;

    // PVector userPos = getUserPosition();

    PVector offset = new PVector(cos(this.angle), sin(this.angle)).mult(this.circleRadius);
    PVector target = PVector.add(this.userPos, offset);

    PVector toTarget = PVector.sub(target, this.position);
    toTarget.setMag(this.maxSpeed);
    this.desiredVelocity = toTarget;
  }

   void guideUser(PVector currentDestination) {
    // PVector userPos = getUserPosition();

    // Compute the vector from user to destination
    PVector directionToDestination = PVector.sub(currentDestination, this.userPos).normalize();
    float distanceToDestination = PVector.dist(this.userPos, currentDestination);

    // Desired distance ahead of user, but not beyond the destination
    float desiredDistanceAhead = min(250, distanceToDestination);
    PVector targetPoint = PVector.add(this.userPos, directionToDestination.mult(desiredDistanceAhead));

    // Prevent firefly from moving beyond the destination
    float fireflyDistanceToDestination = this.position.dist(currentDestination);
    if (fireflyDistanceToDestination < distanceToDestination) {
    // Firefly is ahead of the user; adjust targetPoint to stay between user and destination
    targetPoint = PVector.add(this.userPos, directionToDestination.mult(fireflyDistanceToDestination - 20));
    }

    // Move toward target point ahead of user
    PVector toTarget = PVector.sub(targetPoint, this.position);
    toTarget.setMag(0.1f);
    this.velocity.add(toTarget);

    // Keep fireflies close to the user
    float distanceToUser = PVector.dist(this.position, this.userPos);
    if (distanceToUser > maxDistanceFromUser ) {
      PVector pullBack = PVector.sub(this.userPos, this.position);
      pullBack.setMag(0.2f);
      this.velocity.add(pullBack);
    }

    // Slight random movement
    this.velocity.add(PVector.random2D().mult(0.1f));

    // Limit speed
    this.velocity.limit(this.maxSpeed);

    // Since velocity is updated directly, set desiredVelocity to current velocity
    this.desiredVelocity = this.velocity.copy();
  }    


  void circleAroundDestination(PVector currentDestination) {
    this.angle += this.angularSpeed;
    this.cumulativeAngle += this.angularSpeed;

    PVector offset = new PVector(cos(this.angle), sin(this.angle)).mult(this.circleRadius);
    PVector target = PVector.add(currentDestination, offset);

    PVector toTarget = PVector.sub(target, this.position);
    toTarget.setMag(this.maxSpeed);
    this.desiredVelocity = toTarget;
  }

void alignTowardDestination(PVector currentDestination) {
    PVector direction = PVector.sub(currentDestination, userPos).normalize();

    // Calculate distance between user and destination
    float distanceToDestination = PVector.dist(userPos, currentDestination);

    // Map the distance to a spacing value
    float minSpacing = 10;
    float maxSpacing = 80;
    float maxPossibleDistance = dist(0, 0, width, height);

    // Map the distance to spacing
    float spacing = map(distanceToDestination, 0, maxPossibleDistance, minSpacing, maxSpacing);
    spacing = constrain(spacing, minSpacing, maxSpacing);

    // Adjust the base distance to position fireflies further from the user
    float baseDistance = 100;

    // Position fireflies in a line pointing toward the destination
    PVector target = PVector.add(userPos, PVector.mult(direction, baseDistance + (this.index + 1) * spacing));

    PVector toTarget = PVector.sub(target, this.position);
    toTarget.setMag(this.maxSpeed);
    this.desiredVelocity = toTarget;
  }

}
