ArrayList<Car> myCars;
ArrayList<Obstacle> obs;
float turn = 0;
long timeStamp;
float maxFit;
int generationTime, genNum, numCars;
static final int WIDTH_BOUND = 400;

void setup(){
    size(1300, 900, P2D);
    frameRate(60);
    reset();
}

void reset(){
    myCars = new ArrayList<Car>();
    obs = new ArrayList<Obstacle>();
    timeStamp = millis();
    generationTime = 40000;
    genNum = 0;
    maxFit = 0;
    numCars = 50;

    for (int i = 0; i < numCars; i++){
        myCars.add(new Car());
    }
    for (int i = 0; i < 10; i++){
        obs.add(new Obstacle(random(200, (width - WIDTH_BOUND) - 200), random(200, height-200), random(40, 150)));
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
    showMenu();
    displayText();
    //timeGeneration();
}

void displayCars(){
    if (myCars.size() > 0)
        myCars.get(0).turn(turn);

    for (Car c : myCars){
        c.display();
        c.travel();
        c.bound();
    }
    timeGeneration();
}

void showMenu(){
    noStroke();
    rectMode(CORNER);
    fill(120, 120, 120);
    rect(width - WIDTH_BOUND, 0, WIDTH_BOUND, height);
}

void displayObstacles(){
    for (Obstacle o : obs){
        o.display();
        o.bound();
        o.travel();
    }
}

void displayText(){
    float farthest = 0;
    for (Car c : myCars){
        //System.out.println(c.getClosest());
        if (c.getClosest() > farthest)
            farthest = c.getClosest();
    }
    for (Car c : myCars){
        if (c.getFitness(farthest) > maxFit)
            maxFit = c.getFitness(farthest);
    }

    textSize(20);
    fill(0);
    String text = "Generation: " + genNum;
    text += "\nMost Fit: " + round(maxFit);
    //text += "\nFarthest: " + round(farthest);
    text(text, width - WIDTH_BOUND + 10, 25);
}

void timeGeneration(){
    long tempTime = millis();
    if ((tempTime - timeStamp) > generationTime || myCars.size() == 0){
        genNum++;
        //maxFit = 0;
        System.out.println("Breeding");
        breed();
        maxFit = 0;
        timeStamp = tempTime;
    }
}

void breed(){
    float farthest = 0;
    for (Car c : myCars){
        if (c.getClosest() > farthest)
            farthest = c.getClosest();
    }
    ArrayList<Car> pool = new ArrayList<Car>();

    for (Car c : myCars){
        //System.out.println(c.getFitness(farthest) / maxFit);
        int n = int((c.getFitness(farthest) / maxFit) * 100);
        //System.out.println(n);
        for (int i = 0; i < n; i++){
            pool.add(c.copy(true));
        }
    }

    myCars.clear();

    for (int i = 0; i < numCars; i++){
        int randomPos = int(random(0, pool.size() - 2));
        Car newCar = pool.get(randomPos);
        newCar.giveObs(obs);
        myCars.add(newCar);
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
                c.setDead(true);
            }
        }
    }
}

void keyPressed(){
    if (keyCode == LEFT){
        turn = -0.1;
    }

    if (keyCode == RIGHT){
        turn = 0.1;
    }

    if (keyCode == ENTER)
        reset();

    if (key == ' '){
        for (Car c : myCars){
            c.adjustDisplay();
        }
    }

}

void keyReleased(){
    turn = 0;
}
