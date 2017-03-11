// Carla de Beer
// September 2016
// Genetic algorithm to find an optimised solution to the Travelling Salesman Problem.
// The sketch dynamically reads in city data from a file and calculates the shortest distance it can find, linking all cities.
// The actual physical distance on the route, calculated as the Haversine distance, is also shown.
// Specifiable parameters: crossover rate, mutation rate, popuation size, max. no. iterations, elitism generation gap.
// City data obtained from: https://gist.github.com/Miserlou/c5cd8364bf9b2420bb29
// The crossover strategy makes use of Modified Order Crossover (MOX), as described in:
// http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.91.9167&rep=rep1&type=pdf
// Haversine distance formula: 
// http://stackoverflow.com/questions/27928/calculate-distance-between-two-latitude-longitude-points-haversine-formula

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.*;
import java.text.*;
import processing.pdf.*;

BufferedReader reader;
float maxLat, maxLon, minLat, minLon;
ArrayList<Float> latList = new ArrayList();
ArrayList<Float> lonList = new ArrayList();
ArrayList<String> nameList = new ArrayList();
ArrayList<Float> tmpLat = new ArrayList();
ArrayList<Float> tmpLon = new ArrayList();

int NUM_CITIES = 50;
int generation = 0;
int maxGeneration = 350;
int numPop = 5000;
double crossoverRate = 85.0;
double mutationRate = 25.0;
double generationGap = 25.0;
double sumHaversine = 0.0;

RandomStrategy randomStrategy;

ArrayList<City> path = new ArrayList();
ArrayList<City> pathTrue = new ArrayList();
ArrayList<Route> populationList = new ArrayList<Route>();

color pink = color(245, 30, 95);
color bg = color(30);
color white = color(250);
color lightWhite = color(250);

PFont fontHeader;
PFont fontBody, fontBodyBold, fontBodyItalic;

int offset = 60;
int indent = 65;

double record = 0.0;
int converge = 0;
boolean isRecord = false;
String result;

Date dNow;
SimpleDateFormat ft;

void setup() {
  size(800, 800);
  pixelDensity(displayDensity());
  frameRate(60);
  reader = createReader("cities.txt");
  fontHeader = createFont("ArialMT.vlw", 20);
  fontBody = createFont("ArialMT", 12);
  fontBodyBold = createFont("Arial-BoldMT", 12);
  fontBodyItalic = createFont("Arial-ItalicMT", 12);
}

void draw() {
  if (isRecord) {
    dNow = new Date();
    ft = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
    beginRecord(PDF, "./PDF/" + ft.format(dNow) + ".pdf");
    //beginRecord(PDF, "./PDF/" + args[0] + ".pdf");
  }
  background(bg);
  if (generation >= maxGeneration - 1) {
    noLoop();
  }
  if (frameCount < NUM_CITIES + 10) {
    path.clear();
    pathTrue.clear();
    init();
  } else if (frameCount >= NUM_CITIES + 10) {
    randomStrategy.calculateOptimal();
    randomStrategy.calculateBestEver();
    randomStrategy.generatePopulation();
    generation++;

    if (Math.abs(record - randomStrategy.getBestFitness()) > 0.00001) {
      converge = generation;
    }

    record = randomStrategy.getBestFitness();

    beginShape();
    noFill();
    stroke(pink, 200);
    strokeWeight(2);
    for (City c : randomStrategy.getBestSolution()) {
      stroke(pink, 200);
      vertex((float)c.lon, (float)c.lat);
    }
    endShape();

    strokeWeight(1);

    for (City c : path) {
      fill(lightWhite, 180);
      ellipse((float)c.lon, (float)c.lat, 8, 8);
      fill(lightWhite, 180);
      //if (c.name.equals("Washington") || c.name.equals("Seattle") || 
      //  c.name.equals("Indianapolis") || c.name.equals("Oklahoma City") || 
      //  c.name.equals("Portland") || c.name.equals("Milwaukee") ||
      //  c.name.equals("San Antonio") || c.name.equals("Long Beach") ||
      //  c.name.equals("Mesa")) { 
      //  text(c.name, (float)c.lon + 8, (float)c.lat + 15);
      //} else if (c.name.equals("San Francisco")) {
      //  text(c.name, (float)c.lon + 5, (float)c.lat + 19);
      //} else if (c.name.equals("Sacramento") ||
      //  c.name.equals("New York") || c.name.equals("Philadelphia") ) {
      //  text(c.name, (float)c.lon + 8, (float)c.lat - 5);
      //} else if (c.name.equals("Baltimore") ) {
      //  text(c.name, (float)c.lon + 5, (float)c.lat - 10);
      //} else if (c.name.equals("Dallas")) {
      //  text(c.name, (float)c.lon - 30, (float)c.lat - 10);
      //} else if (c.name.equals("Arlington")) {
      //  text(c.name, (float)c.lon + 8, (float)c.lat - 7);
      //} else if (c.name.equals("Oakland")) {
      //  text(c.name, (float)c.lon + 8, (float)c.lat + 8);
      //} else if (c.name.equals("Denver")) {
      //  text(c.name, (float)c.lon + 8, (float)c.lat + 10);
      //} else if (c.name.equals("Albuquerque")) {
      //  text(c.name, (float)c.lon + 8, (float)c.lat + 10);
      //} else if (c.name.equals("Fort Worth")) {
      //  text(c.name, (float)c.lon + 10, (float)c.lat);
      //} else if (c.name.equals("Wichita")) {
        //text(c.name, (float)c.lon + 8, (float)c.lat + 10);
      //} else 
      text(c.name, (float)c.lon + 11, (float)c.lat + 4);
    }

    // Calculate the Haversine distance
    ArrayList<City> bestArray = randomStrategy.getOptimalRoute().getChromosome();
    ArrayList<City> bestTrue = new ArrayList<City>();

    // Fill the bestTrue array with the true coordinate values, 
    // and in the sequence of the most optimal route
    for (int i = 0; i < bestArray.size(); ++i) {
      String str = bestArray.get(i).name;
      for (int j = 0; j < bestArray.size(); ++j) {
        if ((str).equals(pathTrue.get(j).name)) {
          bestTrue.add(new City(pathTrue.get(j)));
        }
      }
    }

    for (int i = 0; i < NUM_CITIES - 1; ++i) {
      sumHaversine += haversine(bestTrue.get(i).lon, bestTrue.get(i + 1).lon, 
        bestTrue.get(i).lat, bestTrue.get(i + 1).lat);
    }

    String haversineDistance = convertToCommaString((float)sumHaversine);
    result = Double.toString(sumHaversine);
    printText(haversineDistance);
    //System.out.println(sumHaversine);
    sumHaversine = 0.0;
  }

  if (generation == maxGeneration - 2) {
    isRecord = true;
  } else if (generation == maxGeneration - 1) {
    BufferedWriter writer = null;
    try {
      writer = new BufferedWriter(
        new FileWriter("results.csv", true)); 
      writer.write(result + ", " + converge);
      writer.write("\n");
      println("RESULT: " + result);
    }
    catch (IOException e) {
      println("Error: " + e.getMessage());
      e.printStackTrace();
    }
    finally {
      if (writer != null) {
        try {
          writer.close();
        } 
        catch (IOException e) {
          println("Error: " + e.getMessage());
        }
      }
    }
    endRecord();
    //exit();
  }

  if (isRecord) {
    isRecord = false;
    endRecord();
  }
}

double haversine(double lon1, double lon2, double lat1, double lat2) {
  double p = 0.017453292519943295;
  double a = 0.5 - Math.cos((lat2 - lat1) * p) / 2
    + Math.cos(lat1 * p) * Math.cos(lat2 * p) * (1 - Math.cos((lon2 - lon1) * p)) / 2;
  return 12742 * Math.asin(Math.sqrt(a));
}

void init() {
  fill(white);
  textFont(fontHeader);
  text("Parsing the city data", 290, 350);
  parse(reader, latList, lonList, nameList);

  for (int i = 0; i < latList.size(); ++i) {
    tmpLat.add(latList.get(i));
    tmpLon.add(lonList.get(i));
  }

  Collections.sort(tmpLat);
  Collections.sort(tmpLon);

  maxLat = tmpLat.get(0);
  minLat = tmpLat.get(tmpLat.size() - 1);
  maxLon = tmpLon.get(0);
  minLon = tmpLon.get(tmpLon.size() - 1);

  for (int i = 0; i < latList.size(); ++i) {
    float xx = map(lonList.get(i), minLon, maxLon, offset, width - 200);
    float yy = map(latList.get(i), minLat, maxLat, offset, height - 60);
    path.add(new City(xx, yy, nameList.get(i)));
    pathTrue.add(new City(lonList.get(i), latList.get(i), nameList.get(i)));
  }

  populationList = new ArrayList<Route>();
  for (int i = 0; i < numPop; ++i) {
    populationList.add(new Route(path, true));
  }
  randomStrategy = new RandomStrategy(populationList, numPop, maxGeneration, 
    crossoverRate, mutationRate, generationGap, NUM_CITIES);
}

void parse(BufferedReader reader, ArrayList<Float> list1, ArrayList<Float> list2, ArrayList<String> list3) {
  try {
    String line = reader.readLine(); 
    if (line != null) {
      String [] bits = line.split(", "); 
      float lon = float(bits[0]); 
      float lat = -1*float(bits[1]); 
      String name = bits[2]; 
      list1.add(lat);
      list2.add(lon);
      list3.add(name);
    }
  }
  catch(IOException e) {
    println(e);
  }
} 

String convertToCommaString(float fitness) {
  String fitnessString = "";
  StringBuilder resString;
  fitnessString = String.format("%.2f", fitness);
  resString = new StringBuilder(fitnessString);
  int index1 = fitnessString.indexOf('.');
  resString.insert(index1 - 3, ',');
  return resString.toString();
}

String convertToCommaString(int value) {
  if (value >= 1000) {
    StringBuilder resString;
    resString = new StringBuilder(Integer.toString(value));
    if (value >= 1000 && value < 10000) {
      resString.insert(1, ',');
    } else if (value >= 10000) {
      resString.insert(2, ',');
    }
    return resString.toString();
  }
  return Integer.toString(value);
}

void printText(String haversineDistance) {
  fill(lightWhite, 180);
    textFont(fontBodyBold);
  text("Travelling to the " + NUM_CITIES + " largest cities in the US ", offset, height - 235);
  fill(lightWhite, 180);
  textFont(fontBodyItalic);
  text("Genetic Algorithm Parameters", offset, height - 195);
  text("*  Generations: " + convertToCommaString(generation), indent, height - 175);
  text("*  Population size: " + convertToCommaString(numPop) + " individuals", indent, height - 155);
  text("*  Crossover rate: " + crossoverRate + "%", indent, height - 135);
  text("*  Mutation rate: " + mutationRate + "%", indent, height - 115);
  text("*  Elitism generation gap: " + convertToCommaString(randomStrategy.numElite) + 
    " individuals", indent, height - 95);
  fill(lightWhite);
  textFont(fontBody);
  text("Convergence at generation: " + converge, offset, height - 55);
  text("Total distance travelled: " + haversineDistance + " km (Haversine distance)", offset, height - 35);
}

void keyReleased() {
  if (key == 'P' || key == 'p') {
    isRecord = !isRecord;
  }
}