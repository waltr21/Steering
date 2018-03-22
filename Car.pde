public class Car{
    private PVector pos;
    private float angle, acceleration, size, rate, maxSpeed, maxTurnRad;
    private float distanceTraveled, closetCall;
    private boolean displaySensor, isDead;
    private ArrayList<Sensor> sensors;
    private ArrayList<Obstacle> obs;

    /**
     * Constructor for the car that creates new car with random sensors.
     */
    public Car(){
        initVariables();
        int numSensors = int(random(1, 6));

        for (int i = 0; i < numSensors; i++){
            float tempLength = random(30, 150);
            float tempRange = random(10, 80);
            float tempAngle = random(-PI,PI);
            float tempWeight = random(0, 4);
            sensors.add(new Sensor(tempLength, tempRange, tempAngle, tempWeight));
        }
    }

    /**
     * Constructor for the car class that passes down the sensors from the
     * parent class.
     * @param parentSensors ArrayList of sensors from the parent.
     */
    public Car(ArrayList<Sensor> parentSensors, boolean mutation){
        initVariables();
        for (Sensor s : parentSensors){
            sensors.add(s);
        }

        // If the copy is being handed down from a parent.
        if (mutation){
            int n = int(random(100));
            // Five percent chance of mutation
            if (n < 5){
                int n1 = int(random(100));
                // Fifty percent chance of gaining a sensor or losing a sensor.
                if (n1 > 50){
                    float tempLength = random(30, 150);
                    float tempRange = random(10, 80);
                    float tempAngle = random(-PI,PI);
                    float tempWeight = random(0, 4);
                    sensors.add(new Sensor(tempLength, tempRange, tempAngle, tempWeight));
                }
                else{
                    if (sensors.size() > 0)
                        sensors.remove(sensors.size()-1);
                }
            }
        }
    }

    public void initVariables(){
        pos = new PVector(0, 0);
        size = 20;
        angle = random(-PI, PI);
        acceleration = 0;
        maxSpeed = 3;
        maxTurnRad = 0.1;
        displaySensor = false;
        isDead = false;
        distanceTraveled = 0;
        closetCall = 999999;
        rate = 0.05;
        sensors = new ArrayList<Sensor>();
        obs = new ArrayList<Obstacle>();
    }

    /**
     * Travel in the direction of the current car's angle. Also calculate the
     * distance traveled with the acceleration and calculate the closest distance to
     * an obstacle.
     */
    public void travel(){
        if (!isDead){
            //Direction of travel.
            PVector velocity = PVector.fromAngle(angle);

            //Limit acceleration
            if (acceleration > maxSpeed)
                acceleration = maxSpeed;
            else if (acceleration < -1)
                acceleration = -1;
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
    }

    /**
     * Give each sensor an array of the objects in the world.
     * @param newObs [description]
     */
    public void giveObs(ArrayList<Obstacle> newObs){
        for (Sensor s : sensors){
            s.giveObs(newObs);
        }
        for (Obstacle o : newObs){
            obs.add(o);
        }
    }

    /**
     * Keep the car in bounds by sending it to the other side of the box if out of bounds.
     */
    public void bound(){
        //Bound the X barriers
        if (pos.x - size/2 > width - WIDTH_BOUND){
            pos.x = 0 - size/2;
        }
        else if (pos.x + size/2 < 0){
            pos.x = (width - WIDTH_BOUND) + size/2;
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
    public Car copy(boolean mutation){
        ArrayList<Sensor> sensorCopy = new ArrayList<Sensor>();
        for (Sensor s : sensors){
            sensorCopy.add(s.copy());
        }
        return new Car(sensorCopy, mutation);
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

    public float getClosest(){
        return closetCall;
    }

    public void setDead(boolean b){
        isDead = b;
    }

    public float getFitness(float farthest){
        return distanceTraveled * (closetCall / farthest);
    }

    public ArrayList<Sensor> getSensors(){
        return sensors;
    }

    /**
     * Displays the car and each of the sensors.
     */
    public void display(){
        if (!isDead){
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

}
