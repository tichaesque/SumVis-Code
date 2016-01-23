
class PlotPoint {
  // the display width for the spy plot
  private float plotWidth = 400; 
  private float ellipsesize = plotWidth/plotsize;
  
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
        fill(#ff6666); 
      }
      else {
        fill(#81d8d0);
      }
      
      float xPosMapped = map(xPos, 0, plotsize-1, 0, plotWidth);
      float yPosMapped = map(yPos, 0, plotsize-1, 0, plotWidth);
      
      ellipse(xPosMapped,yPosMapped,ellipsesize,ellipsesize); 
    }
    
    
  }
  
}