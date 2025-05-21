// Filename: detection_project.pde
// Author: Gabriel Sullivan
// Purpose: This project handles a collision box which activates a camera effect when
//          a tracked object enters the collision box

import processing.video.*;
import processing.sound.*;

// Classname: EffectBox
// Purpose: handles the collision box that changes video effects
class EffectBox {
    float x, y, width, height;

    // Constructor
    public EffectBox(float x, float y, float width, float height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    } // end constructor

    // Function name: display
    // Purpose: displays the collision box
    // Input: none
    // Output: none
    void display() {
        stroke(255);
        fill(0,0,0,0);
        rectMode(CORNER);
        rect(x, y, width, height);
    } // end display
} // end class EffectBox

EffectBox effectBox;
SoundFile sound;
Capture video;
PImage prevFrame; // Previous Frame

float threshold = 100; // How different must a pixel be to be a "motion" pixel
float boxX = 400;
float boxY = 100;
float boxWidth = 260;
float boxHeight = 400;

// Function name: setup
// Purpose: runs once at startup
// Input: none
// Output: none
void setup() {
    size(1040, 640); // set the window size
    background(0); // create a white background
    sound = new SoundFile(this, "thunder.mp3");
    video = new Capture(this, 1040, 640);
    video.start();
    
    prevFrame = createImage(video.width, video.height, RGB); // Create an empty image the same size as the video
    effectBox = new EffectBox(boxX, boxY, boxWidth, boxHeight); // create the box
} // end setup

// Function name: captureEvent
// Purpose: runs when a new frame is available
// Input: Capture video, the video to be captured
// Output: none
void captureEvent(Capture video) {
    // Save previous frame for motion detection!!
    prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
    prevFrame.updatePixels();

    video.read();
} // end captureEvent

// Function name: draw
// Purpose: runs once every frame
// Input: none
// Output: none
void draw() {
    background(0);

    loadPixels();
    video.loadPixels();
    prevFrame.loadPixels();

    // These are the variables we'll need to find the average X and Y
    float sumX = 0;
    float sumY = 0;
    int motionCount = 0; 

    // Begin loop to walk through every pixel
    for (int x = 0; x < video.width; x++ ) {
        for (int y = 0; y < video.height; y++ ) {
            // What is the current color
            color current = video.pixels[x+y*video.width];

            // What is the previous color
            color previous = prevFrame.pixels[x+y*video.width];

            // Step 4, compare colors (previous vs. current)
            float r1 = red(current); 
            float g1 = green(current);
            float b1 = blue(current);
            float r2 = red(previous); 
            float g2 = green(previous);
            float b2 = blue(previous);

            // Motion for an individual pixel is the difference between the previous color and current color.
            float diff = dist(r1, g1, b1, r2, g2, b2);

            // If it's a motion pixel add up the x's and the y's
            if (diff > threshold) {
                sumX += x;
                sumY += y;
                motionCount++;
            }
        }
    }

    // average location is total location divided by the number of motion pixels.
    float avgX = sumX / motionCount; 
    float avgY = sumY / motionCount; 

    // Draw a circle based on average motion
    smooth();
    noStroke();

    if(avgX > boxX && avgX < boxX + boxWidth && avgY > boxY && avgY < boxY + boxHeight) {
        fill(255);
        tint(0, 0, 255);
        sound.play();
    } else {
        fill(0);
        noTint();
        sound.stop();
    }

    image(video, 0, 0);
    saveFrame("captures/frame-####.jpg");

    ellipse(avgX, avgY, 16, 16);

    effectBox.display();
} // end draw
