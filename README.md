# Steering
Evolutionary algorithm to teach "cars" how to avoid obstacles.

## The Sensor:
Each sensor is given a length, range, angle, and weight to determine the desired angle it wishes to be traveling at. This desired angle is represented as the opposite of the current angle that the sensor is pointing at (current angle + PI). The weight of how "badly" this sensor wants to turn to this direction is determined by how close an obstacle is to the sensor, along with the initial weight given to the sensor. A higher weight makes the sensor more "sensative" (See code in Sensor.pde to see exactly how this is calculated). The desired angle of the sensor is sent to the car each frame of the sketch.

## The Car:
Cars are always traveling forward, but they are also given the ability to turn left or right by some radian X. To determine the desired radian the car should turn, the average of the cars sensor's desired angle is taken with respect to their weight. Sensors have to work together to determine the most optimal turn for the car to take to avoid getting hit. 

## Evolution:
Cars are sent into the world with a time limit of X seconds. If the time limit finishes, or all of the cars have crashed, the current generation is finished and the cars are breeded for the next generation of drivers. To determine how the cars will reproduce, each car keeps track of their own fitness score. This is determined by the overall distance the car traveled multiplied by how close the car came to an obstacle in respect to all of the other cars in the simulation: distanceTraveled * (closest/farthest). Farthest represents the largest distance a car in the simulation has kept from the obstacles. Once the fitness of each car is calculated, a pool of cars is created for the new generation to be created from. How many copies of each car put in the pool is determined by: (carFitness/maxFit) * 100. The new generation randomly selects one parent from the pool and copies their genes (sensors). Each new car is given a 10% mutation rate. A mutation can cause a car to grow a new sensor, or to remove a current one (50/50 chance of each). 
