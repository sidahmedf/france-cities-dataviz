//declare the min and max variables that you need in parseInfo
float minX, maxX;
float minY, maxY;
int totalCount; // total number of places
int minPopulation, maxPopulation;
int minSurface, maxSurface;
int minAltitude, maxAltitude;


void setup() {
  size(800, 800);
}

void draw() {
  background(255);
}

void readData() {
  String[] lines = loadStrings("data/villes.tsv");
}
