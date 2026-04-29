import java.util.Arrays;

float minX, maxX;
float minY, maxY;
int totalCount; 
int minPopulation, maxPopulation;
int minSurface, maxSurface;
int minAltitude, maxAltitude;


City[] cities; 



final int MIN_FILTER = 1000;         
final int MAX_FILTER = 2125250;       

City lastHovered = null;

int MAP_HEIGHT = 600;   
int PANEL_HEIGHT = 60; 


boolean draggingSlider = false;
int SLIDER_Y = MAP_HEIGHT +20 ;        
int SLIDER_LEFT = 20;
int SLIDER_RIGHT = 680;    
int SLIDER_HEIGHT = 40;

int minPopulationToDisplay = MIN_FILTER;
int maxPopulationToDisplay = MAX_FILTER;  

boolean draggingMinHandle = false;  
boolean draggingMaxHandle = false;


float panX = 0;
float panY = 0;
boolean draggingMap = false;
float dragStartX, dragStartY;

float zoomLevel = 1.0;
float zoomMin = 0.5;  
float zoomMax = 10.0;

void setup() {
  size(700, 700);
  pixelDensity(2);
  smooth(8);
  readData();
}

void draw(){
      background(255);  

  for (int i = 0 ; i < totalCount ; i++) {
    
    if (cities[i].population >= minPopulationToDisplay && cities[i].population <= maxPopulationToDisplay) {
      cities[i].display();
  }
  }
  //drawDensityDistribution();
  
  fill(0);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Populations entre : " + minPopulationToDisplay + " et " + maxPopulationToDisplay, 10, 10);  
 
  drawPanel();
  drawSlider();

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
  return map(x, minX, maxX, 0, width) * zoomLevel + panX;
}

float mapY(float y) {
  return map(y, minY, maxY, MAP_HEIGHT, 0) * zoomLevel + panY;
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
    if (cities[i].population >= minPopulationToDisplay && 
        cities[i].population <= maxPopulationToDisplay &&
        cities[i].contains(px, py)) {
      return cities[i];
    }
  }
  return null;
}

void mouseDragged() {
  float clampedX = constrain(mouseX, SLIDER_LEFT, SLIDER_RIGHT);
  
  if (draggingMinHandle) {
    minPopulationToDisplay = sliderToPopulation(clampedX);
    minPopulationToDisplay = min(minPopulationToDisplay, maxPopulationToDisplay);
    redraw();
  } else if (draggingMaxHandle) {
    maxPopulationToDisplay = sliderToPopulation(clampedX);
    maxPopulationToDisplay = max(maxPopulationToDisplay, minPopulationToDisplay);
    redraw();
  } else if (draggingMap) {
    panX += mouseX - dragStartX;
    panY += mouseY - dragStartY;
    dragStartX = mouseX;
    dragStartY = mouseY;
    redraw();
  }
}


void mousePressed() {
  float minHandleX = populationToSlider(minPopulationToDisplay);
  float maxHandleX = populationToSlider(maxPopulationToDisplay);
  
  if (abs(mouseX - minHandleX) < 15 && abs(mouseY - SLIDER_Y) < 15) {
    draggingMinHandle = true;
  } else if (abs(mouseX - maxHandleX) < 15 && abs(mouseY - SLIDER_Y) < 15) {
    draggingMaxHandle = true;
  } else if (mouseY < MAP_HEIGHT) {  
    City clicked = pick(mouseX, mouseY);
    if (clicked != null) {
      clicked.selected = !clicked.selected;
      redraw();
    } else {
      // no city clicked — start panning
      draggingMap = true;
      dragStartX = mouseX;
      dragStartY = mouseY;
    }
  }
}


void mouseReleased() {
  draggingMinHandle = false;
  draggingMaxHandle = false;
  draggingMap = false;
}

float populationToSlider(int pop) {
  return map(log(pop), log(MIN_FILTER), log(MAX_FILTER), SLIDER_LEFT, SLIDER_RIGHT);
}

int sliderToPopulation(float sliderX) {
  float logPop = map(sliderX, SLIDER_LEFT, SLIDER_RIGHT, log(MIN_FILTER), log(MAX_FILTER));
  return (int)constrain(exp(logPop), MIN_FILTER, MAX_FILTER);
}



void drawSlider() {
  float minHandleX = populationToSlider(minPopulationToDisplay);
  float maxHandleX = populationToSlider(maxPopulationToDisplay);
  
  noStroke();
  fill(225);
  rect(SLIDER_LEFT, SLIDER_Y - SLIDER_HEIGHT/2, SLIDER_RIGHT - SLIDER_LEFT, SLIDER_HEIGHT, 4);
  
  drawHistogram();
  
  fill(60, 0, 100);
  noStroke();
  rect(minHandleX - 2, SLIDER_Y - SLIDER_HEIGHT/2, 4, SLIDER_HEIGHT, 2);  
  fill(60, 0, 100);
  rect(minHandleX - 8, SLIDER_Y - SLIDER_HEIGHT/2 - 8, 16, 10, 3); 
  // max handle — same
  fill(60, 0, 100);
  noStroke();
  rect(maxHandleX - 2, SLIDER_Y - SLIDER_HEIGHT/2, 4, SLIDER_HEIGHT, 2);
  fill(60, 0, 100);
  rect(maxHandleX - 8, SLIDER_Y - SLIDER_HEIGHT/2 - 8, 16, 10, 3);
}

void drawPanel() {
  noStroke();
  fill(255);  
  rect(0, MAP_HEIGHT, width, PANEL_HEIGHT);
}


void drawHistogram() {
  int numBars = 50;
  float barWidth = (float)(SLIDER_RIGHT - SLIDER_LEFT) / numBars;
  
  int[] counts = new int[numBars];
  for (int i = 0; i < totalCount; i++) {
    float pop = cities[i].population;
    if (pop < MIN_FILTER || pop > MAX_FILTER) continue;
    
    // use log scale to place city in correct bar
    float t = map(log(pop), log(MIN_FILTER), log(MAX_FILTER), 0, 1);
    int barIndex = constrain((int)(t * numBars), 0, numBars - 1);
    counts[barIndex]++;
  }
  
  int maxCount = 0;
  for (int c : counts) maxCount = max(maxCount, c);
  
  // draw bars
  float trackTop = SLIDER_Y - SLIDER_HEIGHT/2;
  float minHandleX = populationToSlider(minPopulationToDisplay);
  float maxHandleX = populationToSlider(maxPopulationToDisplay);
  
  for (int i = 0; i < numBars; i++) {
    float barX = SLIDER_LEFT + i * barWidth;
    float barH = map(counts[i], 0, maxCount, 0, SLIDER_HEIGHT - 4);  // was SLIDER_HEIGHT
    float barY = (SLIDER_Y + SLIDER_HEIGHT/2) - barH;  // was trackTop + SLIDER_HEIGHT - barH
    
    boolean inRange = (barX >= minHandleX && barX + barWidth <= maxHandleX);
    if (inRange) {
      fill(150, 100, 200, 220);  
    } else {
      fill(180, 180, 180, 180);  
    }
    noStroke();
    rect(barX, barY, barWidth - 1, barH);  
  }
}


void mouseWheel(MouseEvent event) {
  if (mouseY > MAP_HEIGHT) return;
  
  float delta = event.getCount();
  float oldZoom = zoomLevel;
  zoomLevel -= delta * 0.1;
  zoomLevel = constrain(zoomLevel, zoomMin, zoomMax);
  
  // keep the point under the mouse fixed
  panX = mouseX - (mouseX - panX) * (zoomLevel / oldZoom);
  panY = mouseY - (mouseY - panY) * (zoomLevel / oldZoom);
  
  redraw();
}
