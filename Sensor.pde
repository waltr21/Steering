public class Sensor{
    private float length, range, sensorX, sensorY, angle;
    private ArrayList<Obstacle> obs;

    public Sensor(float l, float r, float a){
        length = l;
        range = r;
        angle = a;
        sensorX = 0;
        sensorY = 0;
    }

    public void giveObs(ArrayList<Obstacle> newObs){
        for (Obstacle o : newObs){
            obs.add(o);
        }
    }

    public float desiredAngle(){

    }



    public void display(float x, float y, float a){
        //Display the sensor line (red)
        pushMatrix();
        translate(x, y);
        rotate(a + angle);
        stroke(256 ,0 ,0);
        line(0, 0, length, 0);
        popMatrix();

        //Find the x and y increments for the center point of the circle.
        float tempX = cos(a + angle) * length;
        float tempY = sin(a + angle) * length;
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
