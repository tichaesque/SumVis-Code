/******* FOR THE SPY PLOT *******/
// The spy plot, represented as a 2D boolean array.
// if SpyPlot[u][v] is true, that means there is an edge from u->v
PlotPoint[][] SpyPlotPoints; 
SpyPlot theSpyPlot;

int minYAxis = Integer.MAX_VALUE; // smallest number on the Y-axis
int maxYAxis = Integer.MIN_VALUE; // largest number on the Y-axis 
int minXAxis = Integer.MAX_VALUE; // smallest number on the X-axis
int maxXAxis = Integer.MIN_VALUE; // largest number on the X-axis 

int numrows; 
int numcols; 
int plotsize; 

int minNodeID;
int maxNodeID;

class SpyPlot {

  SpyPlot() {
  }

  void prepareSpyPlot() {

    String path = dataPath("");
    File[] files = listFiles(path);
    for (int i = 0; i < files.length; i++) { 
      String filename = files[i].getName();

      // use the first model file that is found in the data directory as input
      if (filename.endsWith(".out")) {
        spyplotdata = filename; 
        break;
      }
    }

    // put the full data into an array
    String[] inputGraph = loadStrings(spyplotdata); 

    // iterate through data once to establish the range of node numbers
    for (int i = 0; i < inputGraph.length; i++) {
      int rowVertex = int(split(inputGraph[i], ',')[0]); 
      int colVertex = int(split(inputGraph[i], ',')[1]);

      if (rowVertex > maxYAxis) maxYAxis = rowVertex;
      if (rowVertex < minYAxis) minYAxis = rowVertex; 
      if (colVertex > maxXAxis) maxXAxis = colVertex;
      if (colVertex < minXAxis) minXAxis = colVertex;
    }

    numrows = maxYAxis-minYAxis+1;
    numcols = maxXAxis-minXAxis+1; 

    plotsize = max(maxXAxis, maxYAxis)-min(minXAxis, minYAxis)+1; 
    minNodeID = min(minXAxis, minYAxis);  
    maxNodeID = max(maxXAxis, maxYAxis); 

    SpyPlotPoints = new PlotPoint[plotsize][plotsize]; 

    // initialize SpyPlot
    for (int i = 0; i < plotsize; i++) {
      for (int j = 0; j < plotsize; j++) {
        SpyPlotPoints[i][j] = new PlotPoint(0, 0);
      }
    }

    // iterate through data again to populate the spy plot
    for (int i = 0; i < inputGraph.length; i++) {
      int rowVertex = int(split(inputGraph[i], ',')[0]); 
      int colVertex = int(split(inputGraph[i], ',')[1]);

      int colVal = colVertex-minNodeID; 
      int rowVal = rowVertex-minNodeID;

      // add edge in both directions
      SpyPlotPoints[rowVal][colVal].yPos = rowVal;
      SpyPlotPoints[rowVal][colVal].xPos = colVal; 
      SpyPlotPoints[rowVal][colVal].hasEdge = true;

      SpyPlotPoints[colVal][rowVal].yPos = colVal;
      SpyPlotPoints[colVal][rowVal].xPos = rowVal; 
      SpyPlotPoints[colVal][rowVal].hasEdge = true;
    }
  }

  // draws the SpyPlot
  void display() {
    fill(#f5f5f5);
    rect(0, 0, width/2, height);

    pushMatrix();
    translate((width/2-plotWidth)/2, (height-plotWidth)/2); 

    int step = ceil((maxNodeID-minNodeID+1)/9);

    // now draw the axis labels
    for (int i = minNodeID; i <= maxNodeID; i+=step) {
      float axisPos = map(i, minNodeID, maxNodeID, 0, plotWidth); 

      textAlign(CENTER);
      // x axis labels
      fill(0);
      ellipse(axisPos, -10, plotWidth/plotsize, plotWidth/plotsize);

      text(i, axisPos, -20); 

      textAlign(RIGHT);
      // y axis labels
      fill(0);
      ellipse(-10, axisPos, plotWidth/plotsize, plotWidth/plotsize);

      text(i, -20, axisPos + 5);
    }

    textAlign(LEFT);

    // display the SpyPlot
    for (int i = 0; i < plotsize; i++) {
      for (int j = 0; j < plotsize; j++) {
        SpyPlotPoints[i][j].display();
      }
    }

    popMatrix();
    
    spyPlotRendered = true;
  }
}