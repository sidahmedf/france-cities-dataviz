class City {
  int postalcode;
  String name;
  float x;
  float y;
  float population;
  float surface;
  float altitude;
  float density;


  City(String[] columns) {
    this.postalcode = int(columns[0]);
    this.x = float(columns[1]);
    this.y = float(columns[2]);
    this.name = columns[4];
    this.population = float(columns[5]);
    this.surface = float(columns[6]);
    this.altitude = float(columns[7]);
    

    if (this.surface > 0) {
      this.density = this.population / this.surface;
    } else {
      this.density = 0;
    }
  }

void display() {
  float screenX = mapX(this.x);
  float screenY = mapY(this.y);

  float minR = 0.5;
  float maxR = 18;
  float r = map(sqrt(this.population), sqrt((float)minPopulation), sqrt((float)maxPopulation), minR, maxR);

  float logDensity = log(this.density + 1);
  float maxLogDensity = 10.5; 
  float colorRatio = constrain(map(logDensity, 0, maxLogDensity, 0, 1), 0, 1);
  
  color lowDensity  = color(255, 247, 140);  // yellow = sparse
  color highDensity = color(73,  0,  106);   // purple = dense
  color cityColor = lerpColor(lowDensity, highDensity, colorRatio);

  
  if (r > 5) {
    stroke(255, 150);
    strokeWeight(0.8);
  } else {
    noStroke();
  }
  float alpha = map(r, 0.5, 18, 120, 220);
  fill(cityColor, alpha);
  ellipse(screenX, screenY, r * 2, r * 2);
  }

}
