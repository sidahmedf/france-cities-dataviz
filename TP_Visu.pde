import java.util.Arrays;

float minX, maxX;
float minY, maxY;
int totalCount; 
int minPopulation, maxPopulation;
int minSurface, maxSurface;
int minAltitude, maxAltitude;


City[] cities; 



int minPopulationToDisplay = 10000; 
final int MIN_FILTER = 1000;         
final int MAX_FILTER = 500000;       

City lastHovered = null;

void setup() {
  size(700, 700);
  pixelDensity(2);
  smooth(8);
  readData();
}

void draw(){
      background(255);  

  for (int i = 0 ; i < totalCount ; i++) {
    
    if (cities[i].population >= minPopulationToDisplay) {
      cities[i].display();
  }
  }
  //drawDensityDistribution();
  
  fill(0);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Afficher les populations supérieures à : " + minPopulationToDisplay, 10, 10);

}

void readData() {
  String[] lines = loadStrings("villes.tsv");
  parseInfo(lines[0]);
  cities = new City[totalCount];
  
  for (int i = 2 ; i < lines.length ; ++i) {
    String[] columns = split(lines[i], TAB);
    cities[i-2] = new City(columns);
  }
  
  Arrays.sort(cities, (a, b) -> Float.compare(b.population, a.population));
}


void parseInfo(String line) {
  String infoString = line.substring(2); 
  String[] infoPieces = split(infoString, ',');
  
  totalCount = int(infoPieces[0]);
  minX = float(infoPieces[1]);
  maxX = float(infoPieces[2]);
  minY = float(infoPieces[3]);
  maxY = float(infoPieces[4]);
  minPopulation = int(infoPieces[5]);
  maxPopulation = int(infoPieces[6]);
  minSurface = int(infoPieces[7]);
  maxSurface = int(infoPieces[8]);
  minAltitude = int(infoPieces[9]);
  maxAltitude = int(infoPieces[10]);
}


float mapX(float x) {
  return map(x, minX, maxX, 0, width);
}

float mapY(float y) {
  return map(y, minY, maxY, height, 0); 
}

void drawDensityDistribution() {
  fill(255, 200);
  noStroke();
  rect(0, height - 100, width, 100); 
  
  stroke(255, 0, 0, 50); 
  float plotMaxDensity = 10000; 
  
  for (int i = 0; i < cities.length; i++) {
    float clampedForPlot = min(cities[i].density, plotMaxDensity);
    float xPos = map(clampedForPlot, 0, plotMaxDensity, 0, width);
    
    line(xPos, height - 80, xPos, height - 20);
  }
}


void keyPressed() {
  if (keyCode == UP) {
    minPopulationToDisplay = (int)(minPopulationToDisplay * 1.5);
  } else if (keyCode == DOWN) {
    minPopulationToDisplay = (int)(minPopulationToDisplay / 1.5);
  }

  minPopulationToDisplay = constrain(minPopulationToDisplay, MIN_FILTER, MAX_FILTER);
  redraw();
}



void mouseMoved() {
  City hovered = pick(mouseX, mouseY);
    if (hovered != null) println(hovered.name + " r=" + hovered.r);
  if (hovered != lastHovered) {
    // unhighlight previous
    if (lastHovered != null) lastHovered.hovered = false;
    // highlight new
    if (hovered != null) hovered.hovered = true;
    lastHovered = hovered;
    if (hovered != null) println(hovered.name);
    redraw();
  }
}

City pick(int px, int py) {
  for (int i = cities.length - 1; i >= 0; i--) {
    if (cities[i].population >= minPopulationToDisplay && cities[i].contains(px, py)) {
      return cities[i];
    }
  }
  return null;
}




void mousePressed() {
  City clicked = pick(mouseX, mouseY);
  if (clicked != null) {
    clicked.selected = !clicked.selected;  // toggle on/off
    redraw();
  }
}
