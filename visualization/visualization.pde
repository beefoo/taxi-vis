int canvasW = 2000;
int canvasH = 2000;

String rides_table_file = "rides.csv";
ArrayList<Ride> rides;

void setup() {
  // set the stage
  size(canvasW, canvasH);
  colorMode(RGB, 255, 255, 255, 100);
  smooth();
  noStroke();
  noFill();
  noLoop();
  
  rides = new ArrayList<Ride>();
  Table rides_table = loadTable(rides_table_file, "header");
  float[] bounds = {99999, 99999, -99999, -99999};
  
  for (TableRow row : rides_table.rows()) {
    Ride r = new Ride(row);
    float[] gc = r.getGeoCoords();
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
}

void draw(){
  
  background(#000000);
  
  
  

  saveFrame("output/frame.png");

}

void mousePressed() {
  exit();
}

class Ride
{
  float[] geo_coords;
  int[] coords;
  
  Ride(TableRow _ride) {
    geo_coords = new float[4];
    geo_coords[0] = _ride.getFloat("lt0");
    geo_coords[1] = _ride.getFloat("ln0");
    geo_coords[2] = _ride.getFloat("lt1");
    geo_coords[3] = _ride.getFloat("ln1");
    
    coords = new int[4];
  }
  
  float[] getGeoCoords(){
    return geo_coords;
  }
  
  int[] getCoords(){
    return coords;
  }
  
  void initXY(float[] bounds, int w, int h) {
    coords[0] = (lng - min_lng) / (max_lng - min_lng) * w;
    coords[1] = (1.0 - (lat - min_lat) / (max_lat - min_lat)) * h;
    coords[2] = (lng - min_lng) / (max_lng - min_lng) * w;
    coords[3] = (1.0 - (lat - min_lat) / (max_lat - min_lat)) * h;
  }

}
