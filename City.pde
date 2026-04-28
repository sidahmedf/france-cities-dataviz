final float MIN_RADIUS      = 0.5;
final float MAX_RADIUS      = 18.0;
final float MAX_LOG_DENSITY = 10.5;

class City {
  int postalcode;
  String name;
  float x;
  float y;
  float population;
  float surface;
  float altitude;
  float density;
  
  float r;

  boolean hovered = false;
  
  boolean selected = false;

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

  r = computeR();
  
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
  
if (hovered) {
  // draw the ring
  noFill();
  stroke(255, 80, 0, 230);
  strokeWeight(2.5);
  ellipse(screenX, screenY, (r + 4) * 2, (r + 4) * 2);
  
  // draw the name label
  float labelX = screenX + r + 8;  
  float labelY = screenY;
  
  textSize(12);
  float tw = textWidth(name);
  float th = 16;  // fixed height
  
  // translucent background rectangle
  noStroke();
  fill(255, 200);
  rect(labelX - 2, labelY - th/2, tw + 6, th, 3);  
  
  // city name text
  fill(0);
  textAlign(LEFT, CENTER);
  text(name, labelX, labelY);
}


if (selected) {
  textSize(12);
  float tw = textWidth(name);
  float th = 16;
  float labelX = screenX + r + 8;
  float labelY = screenY;
  
  noStroke();
  fill(255, 150, 0, 220);  // orange background when selected
  rect(labelX - 2, labelY - th/2, tw + 6, th, 3);
  
  fill(255);  // white text
  textAlign(LEFT, CENTER);
  text(name, labelX, labelY);
}



  }


boolean contains(int px, int py) {
  float currentR = computeR();
  return dist(mapX(x), mapY(y), px, py) <= currentR + 1;
}


float computeR() {
  return map(sqrt(population),
             sqrt((float)minPopulation), sqrt((float)maxPopulation),
             MIN_RADIUS, MAX_RADIUS);
}

}
