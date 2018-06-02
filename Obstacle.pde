public class Obstacle{
    private PVector pos, velocity;
    private float size, angle, speed, boundRange, repulseTime;

    /**
     * Constructor for the Obstacle class.
     * @param x Starting X pos
     * @param y Starting Y pos
     * @param s Size of the obstacle.
     */
    public Obstacle(float x, float y, float s){
        pos = new PVector(x, y);
        size = s;
        speed = 0.2;
        boundRange = 150;
        angle = random(-PI, PI);
        repulseTime = 0;
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
     * Send the obstacle in the other direction when called.
     */
    public void repulse(){
        float current = millis();
        if (current - repulseTime > 500){
            angle += PI;
            repulseTime = current;
        }
    }

    /**
     * If the obstacle is out of bounds, then a random (appropriate) angle is chosen for the obstavle
     * to travel out.
     */
    public void bound(){
        if (pos.x < boundRange){
            angle = random(-PI/2, PI/2);
        }
        if (pos.x > (width - WIDTH_BOUND) - boundRange){
            angle = random(PI/2, PI*(3/2));
        }
        if (pos.y < boundRange){
            angle = random(0, PI);
        }
        if (pos.y > height - boundRange){
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
