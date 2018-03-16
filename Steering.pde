ArrayList<Car> myCars;
ArrayList<Obstacle> obs;
float turn = 0;

void setup(){
    size(900,900, P2D);
    frameRate(60);
    myCars = new ArrayList<Car>();
    obs = new ArrayList<Obstacle>();
    for (int i = 0; i < 5; i++){
        myCars.add(new Car());
    }
    for (int i = 0; i < 5; i++){
        obs.add(new Obstacle(random(20,width-20), random(20,height-20), random(10, 100)));
    }
    for (Car c : myCars){
        c.giveObs(obs);
    }
}

void draw(){
    background(51,51,51);
    displayCars();
    displayObstacles();
    detectHit();
}

void displayCars(){
    if (myCars.size() > 0)
        myCars.get(0).turn(turn);
    
    for (Car c : myCars){
        c.display();
        c.travel();
        c.bound();
    }
}

void detectHit(){
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

void displayObstacles(){
    for (Obstacle o : obs){
        o.display();
    }
}

void keyPressed(){
    if (keyCode == LEFT){
        turn = -0.1;
    }

    if (keyCode == RIGHT){
        turn = 0.1;
    }

    if (key == ' '){
        for (Car c : myCars){
            c.adjustDisplay();
        }
    }

}

void keyReleased(){
    turn = 0;
}
