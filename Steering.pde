ArrayList<Car> myCars;
Car displayCar, currentFit;
ArrayList<Obstacle> obs;
long timeStamp;
float maxFit;
boolean showSensor;
int generationTime, genNum, numCars, carsRemaining, survivors;
static final int WIDTH_BOUND = 400;

void setup(){
    size(1300, 850, P2D);
    frameRate(60);
    reset();
}

void reset(){
    myCars = new ArrayList<Car>();
    obs = new ArrayList<Obstacle>();
    displayCar = null;
    currentFit = null;
    generationTime = 40000;
    genNum = 0;
    maxFit = 0;
    numCars = 50;
    carsRemaining = numCars;
    survivors = 0;
    showSensor = false;

    for (int i = 0; i < numCars; i++){
        myCars.add(new Car());
    }

    float obsX = 200;
    float obsY = 200;
    for (int i = 0; i < 8; i++){
        float s = random(40,150);
        obs.add(new Obstacle(obsX, obsY, s));

        if (obsX > width - (WIDTH_BOUND + 200)){
            obsY += 200;
            obsX = 200;
        }
        else{
            obsX += s + 50;
        }
    }

    for (Car c : myCars){
        c.giveObs(obs);
    }
    timeStamp = millis();
}

void draw(){
    background(51,51,51);
    displayCars();
    displayObstacles();
    detectHit();
    showMenu();
    displayText();
    timeGeneration();
}

void displayCars(){
    for (Car c : myCars){
        c.display();
        c.travel();
        c.bound();
    }
}

void showMenu(){
    noStroke();
    rectMode(CORNER);
    fill(170, 170, 170);
    rect(width - WIDTH_BOUND, 0, WIDTH_BOUND, height);
}

void displayObstacles(){
    for (int i = 0; i < obs.size(); i++){
        Obstacle o = obs.get(i);

        //Repulse obstacles off each other so they do not overlap.
        for (int j = 0; j < obs.size(); j++){
            Obstacle o1 = obs.get(j);
            if (j != i){
                float d = dist(o.getX(), o.getY(), o1.getX(), o1.getY());
                if (d < o1.getSize()/2 + o.getSize()/2){
                    o1.repulse();
                    o.repulse();
                }
            }
        }
        o.display();
        o.bound();
        o.travel();
    }
}

void displayText(){
    // Find out best fit car.
    // float farthest = 0;
    // for (Car c : myCars){
    //     if (c.getClosest() > farthest)
    //         farthest = c.getClosest();
    // }
    //
    float tempFit = 0;
    for (Car c : myCars){
        if (c.getNewFitness() > tempFit){
            maxFit = c.getNewFitness();
            tempFit = c.getNewFitness();
            currentFit = c;
        }
    }

    textSize(20);
    fill(0);
    String left = "Generation: " + genNum;
    left += "\nMost Fit: " + round(maxFit);
    float percent = (float) survivors / numCars;
    left += "\nOverall Fitness: " + round(percent * 100.0) + "%";
    String right = "Time: " + (round(generationTime - (millis() - timeStamp))) / 1000;
    String mid = "Current Best: ";
    textAlign(LEFT);
    text(left, width - WIDTH_BOUND + 10, 25);
    text(right, width - 100, 25);
    textAlign(CENTER);
    text(mid, width - WIDTH_BOUND/2, 200);
    if (displayCar != null){
        displayCar.adjustDisplay(true);
        displayCar.setX(width - WIDTH_BOUND/2);
        displayCar.setY(400.0);
        displayCar.setAngle(0);
        //scale(2);
        displayCar.display();
        //scale(1);

    }
}

void timeGeneration(){
    long tempTime = millis();
    if ((tempTime - timeStamp) > generationTime || carsRemaining == 0){
        genNum++;
        timeStamp = tempTime;
        survivors = carsRemaining;
        displayCar = new Car(currentFit);
        breed();
        maxFit = 0;
        showSensor = false;
        carsRemaining = numCars;
    }
}

/**
 * Creates a new generation of cars based on the fitness of the previous generation.
 */
void breed(){
    // Find the car who stayed the farthest away from the obstacles and get that value.
    // This value is used to calculate the fitness of each car.
    // float farthest = 0;
    // for (Car c : myCars){
    //     if (c.getClosest() > farthest)
    //         farthest = c.getClosest();
    // }

    ArrayList<Car> pool = new ArrayList<Car>();

    // Add each car to the pool depending on their fitness
    for (Car c : myCars){
        int n = int((c.getNewFitness() / maxFit) * 100);

        // If the car has a fitness above 99 percent double its size in the gene
        // pool.
        if (c.getNewFitness() / maxFit > 0.99){
            n += n;
        }

        for (int i = 0; i < n; i++){
            pool.add(c);
        }
    }

    // Delete all of the old cars.
    myCars.clear();

    // Pick a random position in the pool and create a new child car from the
    // parent.
    for (int i = 0; i < numCars; i++){
        int randomPos = int(random(0, pool.size() - 2));
        Car newCar = new Car(pool.get(randomPos));
        newCar.giveObs(obs);
        myCars.add(newCar);
    }
}

/**
 * Sensors are put into a breeding pool.
 */
void breed2(){
    // Find the car who stayed the farthest away from the obstacles and get that value.
    // This value is used to calculate the fitness of each car.
    float farthest = 0;
    for (Car c : myCars){
        if (c.getClosest() > farthest)
            farthest = c.getClosest();
    }
    ArrayList<Sensor> sensorPool = new ArrayList<Sensor>();
    ArrayList<Integer> numPool = new ArrayList<Integer>();

    // Add each sensor to the pool X amount of times depending on the cars fitness.
    for (Car c : myCars){
        int n = int((c.getFitness(farthest) / maxFit) * 100);

        for (int i = 0; i < n; i++){
            numPool.add(c.getSensors().size());
            for (Sensor s : c.getSensors()){
                sensorPool.add(s);
            }
        }
    }

    myCars.clear();

    // Select a random num of sensors (depending on the num pool) for the new car to
    // have.
    for (int i = 0; i < numCars; i++){
        int r = int(random(0, numPool.size() - 2));
        int numSensors = numPool.get(r);
        ArrayList<Sensor> newSensors = new ArrayList<Sensor>();
        for (int n = 0; n < numSensors; n++){
            int randPos = int(random(0, sensorPool.size() - 2));
            newSensors.add(sensorPool.get(randPos));
        }
        Car newCar = new Car(newSensors);
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
            if (d < tempObSize + tempCarSize && !c.isDead()){
                c.setDead(true);
                carsRemaining--;
            }
        }
    }
}

void keyPressed(){
    if (keyCode == ENTER)
        reset();

    if (key == ' '){
        showSensor = !showSensor;
        for (Car c : myCars){
            c.adjustDisplay(showSensor);
        }
    }

}
