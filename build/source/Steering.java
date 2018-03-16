import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Steering extends PApplet {

ArrayList<Car> myCars;
ArrayList<Obstacle> obs;
float turn = 0;

public void setup(){
    
    frameRate(60);
    myCars = new ArrayList<Car>();
    obs = new ArrayList<Obstacle>();
    for (int i = 0; i < 1; i++){
        myCars.add(new Car());
    }
    for (int i = 0; i < 5; i++){
        obs.add(new Obstacle(random(20,width-20), random(20,height-20), random(10, 100)));
    }
    for (Car c : myCars){
        c.giveObs(obs);
    }
}

public void draw(){
    background(51,51,51);
    displayCars();
    displayObstacles();
}

public void displayCars(){
    myCars.get(0).turn(turn);
    for (Car c : myCars){
        c.display();
        c.travel();
        c.bound();
    }
}

public void displayObstacles(){
    for (Obstacle o : obs){
        o.display();
    }
}

public void keyPressed(){
    if (keyCode == LEFT){
        turn = -0.1f;
    }

    if (keyCode == RIGHT)
        turn = 0.1f;
}

public void keyReleased(){
    turn = 0;
}
public class Car{
    private PVector pos;
    private float angle, acceleration, size, rate, maxSpeed;
    private ArrayList<Sensor> sensors;

    public Car(){
        pos = new PVector(width/2, height/2);
        size = 20;
        angle = random(-PI, PI);
        acceleration = 0;
        maxSpeed = 1;
        sensors = new ArrayList<Sensor>();
        sensors.add(new Sensor(90, 60, -PI/2, 1));
        rate = 0.05f;
    }

    public void travel(){
        //Direction of travel.
        PVector velocity = PVector.fromAngle(angle);

        //Limit acceleration
        if (acceleration > maxSpeed)
            acceleration = maxSpeed;
        else if (acceleration < 0)
            acceleration = 0;
        else
            acceleration += rate;

        //Give acceleration
        velocity.mult(acceleration);

        pos.add(velocity);
    }

    public void giveObs(ArrayList<Obstacle> newObs){
        for (Sensor s : sensors){
            s.giveObs(newObs);
        }
    }

    public void bound(){
        //Bound the X barriers
        if (pos.x - size/2 > width){
            pos.x = 0 - size/2;
        }
        else if (pos.x + size/2 < 0){
            pos.x = width + size/2;
        }

        //Bound the Y barriers
        if (pos.y - size/2 > height){
            pos.y = 0 - size/2;
        }
        else if (pos.y + size/2 < 0){
            pos.y = height + size/2;
        }
    }

    public void turn(float a){
        angle += a;
        if (a > 0 || a < 0)
            acceleration -= rate + 0.03f;

        if (angle > TWO_PI)
            angle = angle - TWO_PI;
        if (angle < 0)
            angle = TWO_PI + angle;
    }

    public float averageTurn(){
        float total = 0;
        int sum = 0;
        for (Sensor s : sensors){
            AngleWeight temp = s.getDesiredAngle();
            // Create the weight to multiply the angle by (int so we
            // can record the sum for averaging)
            int newWeight = PApplet.parseInt(temp.weight * 100);
            sum += newWeight;
            total += temp.angle * newWeight;
        }

        if (sum > 0){
            return total / sum;
        }

        return 0;
    }

    public void display(){

        pushMatrix();
        rectMode(CENTER);
        translate(pos.x, pos.y);
        noStroke();
        fill(0,200,0);
        rotate(angle);
        rect(0, 0, size, size);
        popMatrix();

        for (Sensor s : sensors){
            s.display(pos.x, pos.y, angle);
        }

        float tempTurn = averageTurn();
        turn(tempTurn);
        // System.out.println("Current angle: " + angle);
        // System.out.println("Average: " + tempTurn);
    }

}
public class Obstacle{
    private PVector pos;
    private float size;

    public Obstacle(float x, float y, float s){
        pos = new PVector(x, y);
        size = s;
    }

    public float getX(){
        return pos.x;
    }

    public float getY(){
        return pos.y;
    }

    public float getSize(){
        return size;
    }

    public void display(){
        ellipseMode(CENTER);
        noStroke();
        fill(100, 100, 100);
        ellipse(pos.x, pos.y, size, size);
    }
}
public class Sensor{
    private float length, range, angle, weight, sensorX, sensorY;
    private float carAngle;
    private ArrayList<Obstacle> obs;

    public Sensor(float l, float r, float a, float w){
        length = l;
        range = r;
        angle = a;
        weight = w;
        sensorX = 0;
        sensorY = 0;
        carAngle = 0;
        obs = new ArrayList<Obstacle>();
    }

    public void giveObs(ArrayList<Obstacle> newObs){
        for (Obstacle o : newObs){
            obs.add(o);
        }
    }

    public AngleWeight getDesiredAngle(){
        float min = 999999;
        Obstacle closest = null;
        //Find the closest obstacle.
        for (Obstacle o : obs){
            float current = dist(o.getX(), o.getY(), sensorX, sensorY);
            if (current < min){
                min = current;
                closest = o;
            }
        }


        float minDistance = (range/2) + (closest.getSize()/2);

        //If the closest obstacle is within our visible range we want to turn.
        if (min <= minDistance){
            // Turn weight is based on how close the obstacle is to the sensor.
            // Farther = smaller weight. Smaller weight = less aggressive turn.
            float distanceWeight = (minDistance - min) / minDistance;
            float goalAngle = (angle + carAngle) + PI;
            return new AngleWeight(abs(carAngle - goalAngle), distanceWeight * weight);

        }
        // If closest obstacle is not in our range we don't want to turn.
        else{
            return new AngleWeight(0, 0);
        }
    }



    public void display(float x, float y, float a){
        carAngle = a;

        //Display the sensor line (red)
        pushMatrix();
        translate(x, y);
        rotate(angle + carAngle);
        stroke(256 ,0 ,0);
        line(0, 0, length, 0);
        popMatrix();

        //Find the x and y increments for the center point of the circle.
        float tempX = cos(angle + carAngle) * length;
        float tempY = sin(angle + carAngle) * length;
        sensorX = x + tempX;
        sensorY = y + tempY;

        //Draw the circle at the end of the line
        pushMatrix();
        translate(sensorX, sensorY);
        noFill();
        stroke(0,50,255);
        ellipseMode(CENTER);
        ellipse(0, 0, range, range);
        popMatrix();

    }
}
  public void settings() {  size(900,900, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Steering" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
