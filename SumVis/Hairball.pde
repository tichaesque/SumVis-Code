class Hairball {
  int numrows;
  int numcols;
  int plotsize;
  int minNodeID;
  int maxNodeID;
  int minYAxis = Integer.MAX_VALUE; // smallest number on the Y-axis
  int maxYAxis = Integer.MIN_VALUE; // largest number on the Y-axis 
  int minXAxis = Integer.MAX_VALUE; // smallest number on the X-axis
  int maxXAxis = Integer.MIN_VALUE; // largest number on the X-axis 

  Node[] nodes; 
  int totalnodes; 

  float diameter;

  String[] structures;

  // We initialize a Cluster with a number of nodes, a diameter, and centerpoint
  Hairball(String dataset, float d, Vec2D center) {

    // Initialize the ArrayList 

    // Set the diameter
    diameter = d;

    structures = loadStrings(dataset); 
    totalnodes = structures.length; 

    nodes = new Node[totalnodes];   

    for (int i = 0; i < totalnodes; i++) {
      int rowVertex = int(split(structures[i], ',')[0]); 
      int colVertex = int(split(structures[i], ',')[1]);

      if (rowVertex > maxYAxis) maxYAxis = rowVertex;
      if (rowVertex < minYAxis) minYAxis = rowVertex; 
      if (colVertex > maxXAxis) maxXAxis = colVertex;
      if (colVertex < minXAxis) minXAxis = colVertex;
    }

    minNodeID = min(minXAxis, minYAxis);   

    // Create the nodes from the edge file
    for (int i = 0; i < totalnodes; i++) {
      nodes[i] = new Node(center.add(Vec2D.randomVector()));
    }

    // Connect all the nodes with a Spring
    for (int i = 0; i < totalnodes; i++) {
      int src = int(split(structures[i], ',')[0]); 
      int dst = int(split(structures[i], ',')[1]);

      VerletParticle2D pi = (VerletParticle2D) nodes[src-minNodeID];
      VerletParticle2D pj = (VerletParticle2D) nodes[dst-minNodeID];

      pi.x = random(width*0.1, width*0.4);
      pj.x = random(width*0.1, width*0.4);
      pi.y = random(height*0.2, height*0.8);
      pj.y = random(height*0.2, height*0.8);
    }
  } 

  // Draw all the internal connections
  void display() {
    rectMode(CORNER); 
    fill(0); 
    rect(0, 0, width/2, height); 
    rectMode(CENTER); 

    for (int i = 0; i < totalnodes; i++) {
      int src = int(split(structures[i], ',')[0]); 
      int dst = int(split(structures[i], ',')[1]);

      VerletParticle2D pi = (VerletParticle2D) nodes[src-minNodeID];
      VerletParticle2D pj = (VerletParticle2D) nodes[dst-minNodeID];

      if (!nodes[src-minNodeID].isSelected && !nodes[dst-minNodeID].isSelected) {
        stroke(#FFFF00, 80);
        strokeWeight(0.75);
      } else if (nodes[src-minNodeID].isSelected && nodes[dst-minNodeID].isSelected) {
        stroke(#FF0000);
        strokeWeight(2);
      }

      line(pi.x, pi.y, pj.x, pj.y);
    }
    
    hairballRendered = true;
  }

  Node[] getNodes() {
    return nodes;
  }
}