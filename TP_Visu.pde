float minX, maxX;
float minY, maxY;
int totalCount; // total number of places
int minPopulation, maxPopulation;
int minSurface, maxSurface;
int minAltitude, maxAltitude;

int x = 1;
int y = 2;

float[] xList;
float[] yList;


void setup() {
  size(800,800);
  pixelDensity(1); // this was set to 2 by processing, but i am forcing it back to 1.
  readData();
}

void draw(){
  background(255);
  //in your draw method
color black = color(0);
  
  for (int i = 0 ; i < totalCount ; i++) {
    // 1. Get the raw coordinates
    float rawX = xList[i];
    float rawY = yList[i];
    
    // 2. Convert them to screen coordinates
    float screenX = mapX(rawX);
    float screenY = mapY(rawY);
    
    // 3. Draw the pixel using the new screen coordinates
    set((int) screenX, (int) screenY, black);
  }
}

void readData() {
  String[] lines = loadStrings("villes.tsv");
  
  parseInfo(lines[0]);
  
  xList = new float[totalCount];
  yList = new float[totalCount];
  
  for (int i = 2 ; i < lines.length ; ++i) {
    String[] columns = split(lines[i], TAB);
    xList[i-2] = float(columns[x]);
    yList[i-2] = float(columns[y]);
  }
  
  

}


void parseInfo(String line) {
  // line.substring(2) skips the first two characters to remove the "# "
  String infoString = line.substring(2); 
  
  // split() chops the text into an array every time it sees a comma
  String[] infoPieces = split(infoString, ',');
  
  // Convert the text chunks into numbers and assign to global variables
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
  return map(x, minX, maxX, 0, 800);
}

float mapY(float y) {
  return map(y, minY, maxY, 800, 0); 
}
