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
