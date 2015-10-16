// Code adapted from:
// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

class Cluster {

  // A cluster is a grouping of nodes
  ArrayList<Glyph> glyphs;
  // A list of all the connected pairs
  ArrayList<VerletParticle2D[]> connections;

  float diameter;
  
  Vec2D center;

  // We initialize a Cluster with a number of nodes, a diameter, and centerpoint
  Cluster(String dataset, float d, Vec2D center_) {

    // Initialize the ArrayList
    glyphs = new ArrayList();
    connections = new ArrayList<VerletParticle2D[]>(); 

    // Set the diameter
    diameter = d;
    
    center = center_; 

    // Create the glyphs
    processStructures(dataset);
   
  }
  
  void processStructures(String dataset) {
    String[] structures = 
      loadStrings(dataset);
      
    // Processes structures
    for(int i = 0; i < structures.length; i++) {
      // The glyph class is the first symbol in the line
      String glyphclass = (split(structures[i], ' '))[0]; 
      /* NEED TO ADD
        - size scaling (proportional to the number of nodes in the structure)
      */
      float size = 30f; 
      
      Glyph g = new Glyph(center.add(Vec2D.randomVector()), size, glyphclass);
      glyphs.add(g); 
      
    }
    
    // Find connections between the glyph structures
    for(int i = 0; i < structures.length; i++) {
      String[] currentStructure = split(structures[i], ' ');
      
      for(int j = 1; j < currentStructure.length; j++) {
        int node1ID = int(currentStructure[j]);
        
        for(int k = i+1; k < structures.length; k++) {
          
          String[] otherStructure = split(structures[k], ' ');
          
          for(int l = 1; l < otherStructure.length; l++) {
          
            int node2ID = int(otherStructure[l]);
            
            if(node1ID == node2ID) {
              VerletParticle2D pi = (VerletParticle2D) glyphs.get(i);
              VerletParticle2D pk = (VerletParticle2D) glyphs.get(k);
              
              physics.addSpring(new VerletSpring2D(pi,pk,diameter,0.01));
              VerletParticle2D[] newConnection = { pi, pk };
              connections.add(newConnection); 
              
              break; 
            }
          }
          
        }
      }
      
    }
    
  }

  void display() {
    // Show all the nodes
    for (int i = 0; i < glyphs.size(); i++) {
      Glyph g = (Glyph) glyphs.get(i);
      g.update(mouseX,mouseY);
      g.display();
    }
  }

  // Draw all the internal connections
  void showConnections() {
    strokeWeight(3);
    stroke(255); 
    
    for (int i = 0; i < connections.size(); i++) {
      VerletParticle2D c1 = (VerletParticle2D) connections.get(i)[0];
      VerletParticle2D c2 = (VerletParticle2D) connections.get(i)[1];
      
      line(c1.x,c1.y,c2.x,c2.y);
    }
  }
/*
  void mouseReleased() {
    for (Glyph g: glyphs) {
      g.setClicked(false); 
    }
  }
  
  void mousePressed() { 
    // Check to see if the mouse was clicked on the box
    for (Glyph g: glyphs) {
      if(g.contains(mouseX,mouseY)) {
        g.setClicked(true); 
        
        break; 
      }
    }
  }*/

  ArrayList getGlyphs() {
    return glyphs;
  }
}