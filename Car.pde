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
        sensors.add(new Sensor(90, 60, PI/2, 1));
        rate = 0.05;
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
            acceleration -= rate + 0.03;

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
            int newWeight = int(temp.weight * 100);
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
