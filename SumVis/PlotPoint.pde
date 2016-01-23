// the display width for the spy plot
float plotWidth = 400; 

class PlotPoint {
  boolean hasEdge;  // is there an edge between the two points?
  boolean selected; // was the point selected? 
  int xPos;         // the column position 
  int yPos;         // the row positiion
  
  PlotPoint(int yPos_, int xPos_) {
    hasEdge = false; 
    selected = false; 
    
    xPos = xPos_; 
    yPos = yPos_; 
  }
  
  void display() {
    noStroke(); 
    
    if(hasEdge) {
      if(selected) {
        fill(#db3d3d); 
      }
      else {
        fill(#cbbeb5);
      }
      
      float xPosMapped = map(xPos, 0, plotsize-1, 0, plotWidth);
      float yPosMapped = map(yPos, 0, plotsize-1, 0, plotWidth);
      
      ellipse(xPosMapped,yPosMapped,4,4); 
    }
    
    
  }
  
}