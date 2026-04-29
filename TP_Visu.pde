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

int MAP_HEIGHT = 480;   
int PANEL_HEIGHT = 120; 


boolean draggingSlider = false;
int SLIDER_Y = MAP_HEIGHT +35 ;        
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
  // === HOW TO RESIZE ===
  // Step 1: Pick your map resolution (X) — map is always a square
  // Step 2: Set Y = X + panel height (currently 120)
  // Step 3: Update MAP_HEIGHT = X and PANEL_HEIGHT to match
  //
  // Example: X=500 → size(500, 620), MAP_HEIGHT=500, PANEL_HEIGHT=120
  // Example: X=600 → size(600, 720), MAP_HEIGHT=600, PANEL_HEIGHT=120
  // Current: X=500 → size(500, 600), MAP_HEIGHT=480, PANEL_HEIGHT=120
  
  size(500, 600);
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
  text("Populations entre : " + formatPop(minPopulationToDisplay) + " et " + formatPop(maxPopulationToDisplay), 10, 10); 
 
  drawPanel();
  drawSlider();
  drawLegend();

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

float sliderMargin =30;  // equal margin on both sides within slider zone

// Add these helper functions so mouse events use the same layout as drawing:
float getSliderLeft()  { return width * 0.35 + sliderMargin; }

float getSliderRight() { return width - sliderMargin; }



float getTrackY()      { return MAP_HEIGHT + PANEL_HEIGHT - 45; }

float getMinHandleX() {
  return map(log(minPopulationToDisplay), log(MIN_FILTER), log(MAX_FILTER), getSliderLeft(), getSliderRight());
}


float getMaxHandleX() {
  return map(log(maxPopulationToDisplay), log(MIN_FILTER), log(MAX_FILTER), getSliderLeft(), getSliderRight());
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
  if (draggingMinHandle) {
    float clampedX = constrain(mouseX, getSliderLeft(), getSliderRight());
    float logPop = map(clampedX, getSliderLeft(), getSliderRight(), log(MIN_FILTER), log(MAX_FILTER));
    minPopulationToDisplay = (int)constrain(exp(logPop), MIN_FILTER, maxPopulationToDisplay);
    redraw();
  } else if (draggingMaxHandle) {
    float clampedX = constrain(mouseX, getSliderLeft(), getSliderRight());
    float logPop = map(clampedX, getSliderLeft(), getSliderRight(), log(MIN_FILTER), log(MAX_FILTER));
    maxPopulationToDisplay = (int)constrain(exp(logPop), minPopulationToDisplay, MAX_FILTER);
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
  float minHandleX = getMinHandleX();
  float maxHandleX = getMaxHandleX();
  float trackY = getTrackY();

  if (abs(mouseX - minHandleX) < 12 && abs(mouseY - trackY) < 12) {
    draggingMinHandle = true;
  } else if (abs(mouseX - maxHandleX) < 12 && abs(mouseY - trackY) < 12) {
    draggingMaxHandle = true;
  } else if (mouseY < MAP_HEIGHT) {
    City clicked = pick(mouseX, mouseY);
    if (clicked != null) {
      clicked.selected = !clicked.selected;
      redraw();
    } else {
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



void drawPanel() {
  noStroke();
  fill(240, 240, 245);
  rect(0, MAP_HEIGHT, width, PANEL_HEIGHT);
  
  // top border line
  stroke(200);
  strokeWeight(1);
  line(0, MAP_HEIGHT, width, MAP_HEIGHT);
  noStroke();
}

void drawSlider() {
  float margin = 20;
  float gap = 20;  // gap between legend and slider
  float legendWidth = 160;  // approximate legend width
  
  float sLeft  = getSliderLeft();
  float sRight = getSliderRight();
  float trackY = getTrackY();
  int trackH = 4;
  int handleR = 6;

  float minHandleX = map(log(minPopulationToDisplay), log(MIN_FILTER), log(MAX_FILTER), sLeft, sRight);
  float maxHandleX = map(log(maxPopulationToDisplay), log(MIN_FILTER), log(MAX_FILTER), sLeft, sRight);
  
  
  // in drawSlider(), before the histogram
fill(100);
textSize(10);
textAlign(LEFT, BOTTOM);
text("Filtrer par population", sLeft, trackY - 35 - 12);

  // histogram above track
 drawHistogram(sLeft, sRight, trackY - trackH/2);  // sits right on top of track

  // track background
  noStroke();
  fill(200);
  rect(sLeft, trackY - trackH/2, sRight - sLeft, trackH, 2);

  // active range
  fill(120, 80, 180);
  rect(minHandleX, trackY - trackH/2, maxHandleX - minHandleX, trackH, 2);

  // handles
  strokeWeight(1.5);
  stroke(80, 0, 130);
  fill(255);
  ellipse(minHandleX, trackY, handleR * 2, handleR * 2);
  ellipse(maxHandleX, trackY, handleR * 2, handleR * 2);
  noStroke();
  
  // centerd dot
  noStroke();
  fill(80, 0, 130);
  ellipse(minHandleX, trackY, 4, 4);
  ellipse(maxHandleX, trackY, 4, 4);

  // value labels
  fill(80);
  textSize(11);
  textAlign(CENTER, TOP);
  text(formatPop(minPopulationToDisplay), minHandleX, trackY + handleR + 2);
  text(formatPop(maxPopulationToDisplay), maxHandleX, trackY + handleR + 2);
}

void drawHistogram(float sliderLeft, float sliderRight, float histBottom) {
  int numBars = 50;
  int histH = 35;  // histogram height
  float barWidth = (float)(sliderRight - sliderLeft) / numBars;

  int[] counts = new int[numBars];
  for (int i = 0; i < totalCount; i++) {
    float pop = cities[i].population;
    if (pop < MIN_FILTER || pop > MAX_FILTER) continue;
    float t = map(log(pop), log(MIN_FILTER), log(MAX_FILTER), 0, 1);
    int barIndex = constrain((int)(t * numBars), 0, numBars - 1);
    counts[barIndex]++;
  }

  int maxCount = 0;
  for (int c : counts) maxCount = max(maxCount, c);
  if (maxCount == 0) return;

  float minHandleX = map(log(minPopulationToDisplay), log(MIN_FILTER), log(MAX_FILTER), sliderLeft, sliderRight);
  float maxHandleX = map(log(maxPopulationToDisplay), log(MIN_FILTER), log(MAX_FILTER), sliderLeft, sliderRight);

  for (int i = 0; i < numBars; i++) {
    float barX = sliderLeft + i * barWidth;
    float barH = map(counts[i], 0, maxCount, 0, histH);
    float barY = histBottom - barH;

    boolean inRange = (barX >= minHandleX && barX + barWidth <= maxHandleX);
    noStroke();
    fill(inRange ? color(100, 60, 180, 255) : color(210, 210, 210, 150));
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

void drawLegend() {
  float margin = 15;
  float legendX = margin;
  float legendY = MAP_HEIGHT + margin;
  float legendWidth = getSliderLeft() - margin * 2;

  // --- SIZE LEGEND ---
  fill(80);
  textSize(10);
  textAlign(LEFT, TOP);
  text("Population (taille)", legendX, legendY);

  int[] refPops = {10000, 100000, 500000};
  String[] refLabels = {"10k", "100k", "500k"};

  float spacing = legendWidth / 3;
  float circleBaseY = legendY + 20;  // top of circle zone

  float[] radii = new float[3];
  for (int i = 0; i < 3; i++) {
    radii[i] = map(sqrt(refPops[i]),
                   sqrt((float)minPopulation), sqrt((float)maxPopulation),
                   MIN_RADIUS, MAX_RADIUS);
  }

  // find tallest circle to align bottoms
  float maxR = max(radii[0], max(radii[1], radii[2]));

  for (int i = 0; i < 3; i++) {
    float cx = legendX + spacing * i + spacing / 2;
    float cy = circleBaseY + maxR;  // all circles bottom-aligned
    noStroke();
    fill(120, 80, 160, 180);
    ellipse(cx, cy, radii[i] * 2, radii[i] * 2);
    fill(80);
    textSize(9);
    textAlign(CENTER, TOP);
    text(refLabels[i], cx, circleBaseY + maxR * 2 + 4);  // label below tallest circle
  }

  // --- COLOR LEGEND --- starts well below circle labels
  float barY = circleBaseY + maxR * 2 + 45;  // was 24, now 45
  float barW = legendWidth - margin;
  float barH = 8;

  fill(80);
  textSize(10);
  textAlign(LEFT, TOP);
  text("Densité (couleur)", legendX, barY - 14);

  for (int i = 0; i < (int)barW; i++) {
    float t = i / barW;
       color c = lerpColor(color(200, 190, 230), color(50, 0, 80), t);  // was (255,240,100)
    stroke(c);
    line(legendX + i, barY, legendX + i, barY + barH);
  }
  noStroke();

  fill(80);
  textSize(9);
  textAlign(LEFT, TOP);
  text("faible", legendX, barY + barH + 3);
  textAlign(RIGHT, TOP);
  text("élevée", legendX + barW, barY + barH + 3);

  // --- VERTICAL SEPARATOR ---
  stroke(200);
  strokeWeight(1);
  float sepX = getSliderLeft() - margin;
  line(sepX, MAP_HEIGHT + 10, sepX, MAP_HEIGHT + PANEL_HEIGHT - 10);
  noStroke();
}



String formatPop(int pop) {
  if (pop >= 1000000) {
    return nf(pop / 1000000.0, 1, 1) + "M";
  } else if (pop >= 1000) {
    return nf(pop / 1000.0, 1, 0) + "k";
  } else {
    return str(pop);
  }
}
