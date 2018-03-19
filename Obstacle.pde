public class Obstacle{
    private PVector pos;
    private float size;

    public Obstacle(float x, float y, float s){
        pos = new PVector(x, y);
        size = s;
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

    public void travel(){

    }

    public void display(){
        ellipseMode(CENTER);
        noStroke();
        fill(100, 100, 100);
        ellipse(pos.x, pos.y, size, size);
    }
}
