// the display width for the spy plot
float plotWidth = 400; 
class PlotPoint {
  private float ellipsesize = max(plotWidth/plotsize, 2);
  
  boolean hasEdge;  // is there an edge between the two points?
  boolean selected; // was the point selected? 
  boolean isFirst;  // is this part of the first structure selected? 
  boolean isSecond; // is this part of the second structure selected?
  boolean isOverlap;// is this part of an overlap?
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
      /*
      if(selected) {
        fill(#ff6666); 
      }*/
      // an overlap
      if(isFirst && isSecond) {
        fill(#98137e);
      }
      else if(isFirst) {
        fill(#ff4444); 
      }
      else if(isSecond) {
        fill(#43dde5);
      }
      else if(!isFirst && !isSecond) {
        fill(#dedede);
      }
      
      float xPosMapped = map(xPos, 0, plotsize-1, 0, plotWidth);
      float yPosMapped = map(yPos, 0, plotsize-1, 0, plotWidth);
      
      ellipse(xPosMapped,yPosMapped,ellipsesize,ellipsesize); 
    }
    
    
  }
  
}