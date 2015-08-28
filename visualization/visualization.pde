int canvasW = 3200;
int canvasH = 3200;

int[] strokeAlphaRange = {0, 10};
float[] strokeWeightRange = {0.01, 1.0};
color colorPickup = #000000;
color colorDropoff = #F2CF73;

String rides_table_file = "rides.csv";
ArrayList<Ride> rides;

void setup() {
  // set the stage
  colorMode(RGB, 255, 255, 255, 100);
  smooth();
  noStroke();
  noFill();
  noLoop();

  rides = new ArrayList<Ride>();
  Table rides_table = loadTable(rides_table_file, "header");
  float[] bounds = {99999, 99999, -99999, -99999};

  // read rows in csv
  for (TableRow row : rides_table.rows()) {
    Ride r = new Ride(row);
    float[] gc = r.getGeoCoords();
    // track min/max of coordinates
    if (gc[0] < bounds[0]) bounds[0] = gc[0];
    if (gc[2] < bounds[0]) bounds[0] = gc[2];
    if (gc[0] > bounds[2]) bounds[2] = gc[0];
    if (gc[2] > bounds[2]) bounds[2] = gc[2];
    if (gc[1] < bounds[1]) bounds[1] = gc[1];
    if (gc[3] < bounds[1]) bounds[1] = gc[3];
    if (gc[1] > bounds[3]) bounds[3] = gc[1];
    if (gc[3] > bounds[3]) bounds[3] = gc[3];
    rides.add(r);
  }

  // determine canvas ratio, w/h
  float lat_range = bounds[2] - bounds[0],
        lng_range = bounds[3] - bounds[1],
        ratio = lng_range / lat_range;
  if (lng_range > lat_range) {
    canvasH = round(1.0 * canvasH / ratio);
  } else {
    canvasW = round(1.0 * canvasW * ratio);
  }
  size(canvasW, canvasH);

  println("Bounds: ["+bounds[0]+","+bounds[1]+","+bounds[2]+","+bounds[3]+"]");

  // update coords
  for(int i=0; i<rides.size(); i++) {
    rides.get(i).initXY(bounds, canvasW, canvasH);
  }
}

void draw(){

  background(#262428);


  for(int i=0; i<rides.size(); i++) {
    Ride r = rides.get(i);
    int[] coords = r.getCoords();
    drawCurve(r.getWavelength(), r.getDistance(), r.getAngle(), coords[0], coords[1], colorPickup, colorDropoff, strokeAlphaRange[0], strokeAlphaRange[1], strokeWeightRange[0], strokeWeightRange[1]);
  }


  saveFrame("output/frame.png");

}

void mousePressed() {
  exit();
}

float angleBetweenPoints(int x1, int y1, int x2, int y2){
  int deltaX = x2 - x1,
        deltaY = y2 - y1;
  return 1.0 * atan2(deltaY, deltaX) * 180.0 / PI;
}

void drawCurve(float wavelength, float distance, float angle, int x1, int y1, color c1, color c2, int a1, int a2, float sw1, float sw2){
  int x = 0,
      y = 0;
  pushMatrix();
  translate(x1, y1);
  rotate(radians(angle));
  for(int x2=1; x2<int(distance); x2++) {
    // calculate interpolation
    float l = 1.0 * x / distance;
    float l2 = 1.0 - sin(radians(l * PI));

    // lerp stroke weight, alpha, color
    float sw = lerp(sw1, sw2, l2);
    float a = lerp(a1, a2, l2);
    color c = lerpColor(c1, c2, l);

    // set stroke weight, alpha, color
    strokeWeight(sw);
    stroke(c, a);

    // determine next point
    int y2 = round(1.0 * sin(-1.0*x2/distance*PI) * wavelength);
    if (angle>90 || angle<-45) {
      y2 = round(1.0 * sin(1.0*x2/distance*PI) * wavelength);
    }

    // draw line, continue
    line(x, y, x2, y2);
    x = x2;
    y = y2;
  }
  popMatrix();
}

class Ride
{
  float[] wavelengthRange = {10, 500};

  float[] geo_coords;
  int[] coords;
  float wavelength, distance, angle;

  Ride(TableRow _ride) {
    geo_coords = new float[4];
    geo_coords[0] = _ride.getFloat("lt0");
    geo_coords[1] = _ride.getFloat("ln0");
    geo_coords[2] = _ride.getFloat("lt1");
    geo_coords[3] = _ride.getFloat("ln1");

    coords = new int[4];
    wavelength = 0.0;
    angle = 0.0;
    distance = 0.0;
  }

  float getAngle(){
    return angle;
  }

  int[] getCoords(){
    return coords;
  }

  float getDistance(){
    return distance;
  }

  float[] getGeoCoords(){
    return geo_coords;
  }

  float getWavelength(){
    return wavelength;
  }

  void initXY(float[] bounds, int w, int h) {
    float min_lat = bounds[0],
          min_lng = bounds[1],
          max_lat = bounds[2],
          max_lng = bounds[3],
          lat0 = geo_coords[0],
          lng0 = geo_coords[1],
          lat1 = geo_coords[2],
          lng1 = geo_coords[3];

    coords[0] = round((lng0 - min_lng) / (max_lng - min_lng) * w);
    coords[1] = round((1.0 - (lat0 - min_lat) / (max_lat - min_lat)) * h);
    coords[2] = round((lng1 - min_lng) / (max_lng - min_lng) * w);
    coords[3] = round((1.0 - (lat1 - min_lat) / (max_lat - min_lat)) * h);

    distance = dist(coords[0], coords[1], coords[2], coords[3]);
    angle = angleBetweenPoints(coords[0], coords[1], coords[2], coords[3]);
    float distance_n = 1.0 * distance / dist(0, 0, w, h);
    wavelength = distance_n * (wavelengthRange[1]-wavelengthRange[0]) + wavelengthRange[0];
  }

}
