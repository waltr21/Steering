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

    public void display(){
        ellipseMode(CENTER);
        noStroke();
        fill(100, 100, 100);
        ellipse(pos.x, pos.y, size, size);
    }
}
