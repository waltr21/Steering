public class Car{
    private PVector pos;
    private float angle, acceleration, size, rate, maxSpeed, maxTurnRad;
    private boolean displaySensor;
    private ArrayList<Sensor> sensors;

    public Car(){
        pos = new PVector(0, 0);
        size = 20;
        angle = random(-PI, PI);
        acceleration = 0;
        maxSpeed = 3;
        maxTurnRad = 0.1;
        displaySensor = true;
        sensors = new ArrayList<Sensor>();
        sensors.add(new Sensor(90, 60, 0, 1));
        sensors.add(new Sensor(90, 60, PI/4, 1));
        sensors.add(new Sensor(90, 60, -PI/4, 1));
        rate = 0.05;
    }

    /**
     * Travel in the direction of the current car's angle.
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

    /**
     * Turns the car based on an input angle.
     * @param a Angle to turn.
     */
    public void turn(float a){
        angle += a;

        // Bring down the acceleration if we are turning more than 0 degrees.
        if (a > 0 || a < 0)
            acceleration -= rate + (0.05 * (a/maxTurnRad));

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
            int newWeight = int(temp.weight * 100);
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
            if (totalAng > 3.1415)
                return -maxTurnRad * avgWeight;
            else
                return maxTurnRad * avgWeight;
        }
        // Turn by 0 if we dont detect any objects.
        return 0;
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
