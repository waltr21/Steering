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
static final int WIDTH_BOUND = 400;

public void setup(){
    
    frameRate(60);
    myCars = new ArrayList<Car>();
    obs = new ArrayList<Obstacle>();
    for (int i = 0; i < 30; i++){
        myCars.add(new Car());
    }
    for (int i = 0; i < 8; i++){
        obs.add(new Obstacle(random(200, (width - WIDTH_BOUND) - 200), random(200, height-200), random(10, 100)));
    }
    for (Car c : myCars){
        c.giveObs(obs);
    }
}

public void draw(){
    background(51,51,51);
    showMenu();
    displayCars();
    displayObstacles();
    detectHit();
}

public void displayCars(){
    if (myCars.size() > 0)
        myCars.get(0).turn(turn);

    for (Car c : myCars){
        c.display();
        c.travel();
        c.bound();
    }
}

public void detectHit(){
    for (int i = myCars.size() - 1; i >= 0; i--){
        Car c = myCars.get(i);
        float tempCarSize = c.getSize()/2;
        for (Obstacle o : obs){
            float tempObSize = o.getSize()/2;
            float d = dist(c.getX(), c.getY(), o.getX(), o.getY());
            if (d < tempObSize + tempCarSize){
                myCars.remove(i);
            }
        }
    }
}

public void showMenu(){
    noStroke();
    rectMode(CORNER);
    fill(188, 200, 219);
    rect(width - WIDTH_BOUND, 0, WIDTH_BOUND, height);
}

public void displayObstacles(){
    for (Obstacle o : obs){
        o.display();
        o.bound();
        o.travel();
    }
}

public void keyPressed(){
    if (keyCode == LEFT){
        turn = -0.1f;
    }

    if (keyCode == RIGHT){
        turn = 0.1f;
    }

    if (key == ' '){
        for (Car c : myCars){
            c.adjustDisplay();
        }
    }

}

public void keyReleased(){
    turn = 0;
}
public class Car{
    private PVector pos;
    private float angle, acceleration, size, rate, maxSpeed, maxTurnRad;
    private float distanceTraveled, closetCall;
    private boolean displaySensor;
    private ArrayList<Sensor> sensors;
    private ArrayList<Obstacle> obs;

    /**
     * Constructor for the car class.
     */
    public Car(){
        initVariables();

        int numSensors = PApplet.parseInt(random(1, 6));
        for (int i = 0; i < numSensors; i++){
            float tempLength = random(30, 150);
            float tempRange = random(10, 80);
            float tempAngle = random(-PI, PI);
            float tempWeight = random(0, 4);
            sensors.add(new Sensor(tempLength, tempRange, tempAngle, tempWeight));
        }
    }

    public Car(ArrayList<Sensor> s){

    }

    public void initVariables(){
        pos = new PVector(0, 0);
        size = 20;
        angle = PI/4;
        acceleration = 0;
        maxSpeed = 3;
        maxTurnRad = 0.1f;
        displaySensor = false;
        distanceTraveled = 0;
        closetCall = 999999;
        sensors = new ArrayList<Sensor>();
        obs = new ArrayList<Obstacle>();
        rate = 0.05f;
    }

    /**
     * Travel in the direction of the current car's angle. Also calculate the
     * distance traveled with the acceleration and calculate the closest distance to
     * an obstacle.
     */
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

        // Turn based on our
        turn(averageTurn());

        //Measure the distance traveled my incrementing by the current acceleration
        // (Cars that are turning more efficiently will be traveling faster giving them
        // a better fitness score)
        distanceTraveled += acceleration;

        calculateClosest();
    }

    /**
     * Give each sensor an array of the objects in the world.
     * @param newObs [description]
     */
    public void giveObs(ArrayList<Obstacle> newObs){
        for (Sensor s : sensors){

            s.giveObs(newObs);
        }
    }

    /**
     * Keep the car in bounds by sending it to the other side of the box if out of bounds.
     */
    public void bound(){
        //Bound the X barriers
        if (pos.x - size > width - WIDTH_BOUND){
            pos.x = 0 - size;
        }
        else if (pos.x + size < 0){
            pos.x = (width - WIDTH_BOUND) + size;
        }

        //Bound the Y barriers
        if (pos.y - size/2 > height){
            pos.y = 0 - size/2;
        }
        else if (pos.y + size/2 < 0){
            pos.y = height + size/2;
        }
    }

    /**
     * Turns the car based on an input angle.
     * @param a Angle to turn.
     */
    public void turn(float a){
        angle += a;

        // Bring down the acceleration if we are turning more than 0 degrees.
        if (a > 0 || a < 0)
            acceleration -= rate + (0.05f * (a/maxTurnRad));

        // Limit the total angle to be between 0 and two pi
        if (angle > TWO_PI)
            angle = angle - TWO_PI;
        if (angle < 0)
            angle = TWO_PI + angle;
    }

    /**
     * Calculates the average of all of the desired angles from each of the sensors
     * based on their weights.
     * @return Final angle the car should desire to turn to as a float.
     */
    public float averageTurn(){
        float total = 0;
        float avgWeight = 0;
        int sum = 0;
        for (Sensor s : sensors){
            AngleWeight temp = s.getDesiredAngle();
            // Create the weight to multiply the angle by (int so we
            // can record the sum for averaging)
            int newWeight = PApplet.parseInt(temp.weight * 100);
            avgWeight += temp.weight;
            sum += newWeight;
            total += temp.angle * newWeight;
        }

        if (sum > 0){
            //Angle we want to turn.
            //This will add up to be the average of the opposites of each of our sensors.
            float totalAng = total / sum;
            avgWeight = avgWeight / sensors.size();

            //Display the desired angle
            if (displaySensor){
                pushMatrix();
                translate(pos.x, pos.y);
                noFill();
                stroke(246, 91, 255);
                rotate(totalAng + angle);
                line(0, 0, 70, 0);
                popMatrix();
            }

            //If our turn is greater than PI then we should turn left becuase it
            // is shorter. (Couldn't use the actual PI variable for rounding issues)
            if (totalAng > 3.1415f)
                return -maxTurnRad * avgWeight;
            else
                return maxTurnRad * avgWeight;
        }
        // Turn by 0 if we dont detect any objects.
        return 0;
    }

    /**
     * Calculates the closest distance the car gets to an obstacle.
     */
    public void calculateClosest(){
        for (Obstacle o : obs){
            float tempDistance = dist(o.getX(), o.getY(), pos.x, pos.y);
            if (tempDistance < closetCall)
                closetCall = tempDistance;
        }
    }

    /**
     * Create a copy of this car object without reference
     * @return The new car copy.
     */
    public Car copy(){
        return new Car();
    }

    public void adjustDisplay(){
        displaySensor = !displaySensor;
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

    public float getFitness(float farthest){
        return distanceTraveled * (closetCall / farthest);
    }

    /**
     * Displays the car and each of the sensors.
     */
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
            s.display(pos.x, pos.y, angle, displaySensor);
        }
    }

}
public class Obstacle{
    private PVector pos, velocity;
    private float size, angle, speed;

    public Obstacle(float x, float y, float s){
        pos = new PVector(x, y);
        size = s;
        speed = 0.4f;
        angle = random(-PI, PI);
    }

    /**
     * Get the X location of the obstacle
     * @return X position as a float
     */
    public float getX(){
        return pos.x;
    }

    /**
     * Get the Y location of the obstacle
     * @return Y position as a float
     */
    public float getY(){
        return pos.y;
    }

    /**
     * Get the size of the obstacle
     * @return Size of the obstacle as a float
     */
    public float getSize(){
        return size;
    }

    /**
     * Move the objects in the desired direction.
     */
    public void travel(){
        velocity = PVector.fromAngle(angle);
        velocity.mult(speed);
        pos.add(velocity);
    }

    /**
     * If the obstacle is out of bounds, then a random (appropriate) angle is chosen for the obstavle
     * to travel out.
     */
    public void bound(){
        if (pos.x < 200){
            angle = random(-PI/2, PI/2);
        }
        if (pos.x > (width - WIDTH_BOUND) - 200){
            angle = random(PI/2, PI*(3/2));
        }
        if (pos.y < 200){
            angle = random(0, PI);
        }
        if (pos.y > height - 200){
            angle = random(PI, TWO_PI);
        }
    }

    /**
     * Draw/translate the obstacle as a circle at a specific X and Y.
     */
    public void display(){
        pushMatrix();
        ellipseMode(CENTER);
        noStroke();
        fill(100, 100, 100);
        translate(pos.x, pos.y);
        ellipse(0, 0, size, size);
        popMatrix();
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

    /**
     * Give the sensor a reference of each of the obstacles in the world.
     * @param newObs ArrayList of Obstacles in the given world.
     */
    public void giveObs(ArrayList<Obstacle> newObs){
        for (Obstacle o : newObs){
            obs.add(o);
        }
    }

    /**
     * Gives the
     * @return [description]
     */
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
            // This is the angle that we want out car to be traveling at (Opposite of our current angle)
            float goalAngle = (angle + carAngle) + PI;
            // Get the difference between the goal and current angle. Pack into angle weight and return.
            return new AngleWeight(abs(carAngle - goalAngle), distanceWeight * weight);

        }
        // If closest obstacle is not in our range we don't want to turn.
        else{
            return new AngleWeight(0, 0);
        }
    }


    /**
     * Update and show the sensor
     * @param x  X location of the car
     * @param y  Y location of the car
     * @param a  Current angle of the car
     * @param ds Display sensor of the car or not.
     */
    public void display(float x, float y, float a, boolean ds){
        carAngle = a;

        //Display the sensor line (red)
        pushMatrix();
        translate(x, y);
        rotate(angle + carAngle);
        stroke(256 ,0 ,0);
        if (ds)
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
        if (ds)
            ellipse(0, 0, range, range);
        popMatrix();

    }

}
  public void settings() {  size(1300, 900, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Steering" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
