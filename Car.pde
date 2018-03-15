public class Car{
    private PVector pos;
    private float angle, acceleration, size, rate;
    private ArrayList<Sensor> sensors;

    public Car(){
        pos = new PVector(width/2, height/2);
        size = 20;
        angle = random(-PI, PI);
        acceleration = 0;
        sensors = new ArrayList<Sensor>();
        sensors.add(new Sensor(90, 70, 0));
        rate = 0.05;
    }

    public void travel(){
        //Direction of travel.
        PVector velocity = PVector.fromAngle(angle);

        //Limit acceleration
        if (acceleration > 3)
            acceleration = 3;
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
    }

}
