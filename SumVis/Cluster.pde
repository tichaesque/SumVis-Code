// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Force directed graph
// Heavily based on: http://code.google.com/p/fidgen/

class Cluster {

  // A cluster is a grouping of nodes
  ArrayList<Glyph> glyphs;

  float diameter;
  
  Vec2D center;

  // We initialize a Cluster with a number of nodes, a diameter, and centerpoint
  Cluster(String dataset, float d, Vec2D center_) {

    // Initialize the ArrayList
    glyphs = new ArrayList();

    // Set the diameter
    diameter = d;
    
    center = center_; 

    // Create the glyphs
    processStructures(dataset);
    

  }
  
  void processStructures(String dataset) {
    String[] structures = 
      loadStrings(dataset);
      
    //processes structures
    for(int i = 0; i < structures.length; i++) {
      String glyphclass = (split(structures[i], ' '))[0]; 
      /* NEED TO ADD
        - size scaling (proportional to the number of nodes in the structure)
      */
      float size = 30f; 
      
      Glyph g = new Glyph(center.add(Vec2D.randomVector()), size, glyphclass);
      //Glyph g = new Glyph(center.add(Vec2D.randomVector())); 
      glyphs.add(g); 
      
    }
    
    // Connect all the nodes with a Spring
    for (int i = 1; i < glyphs.size(); i++) {
      VerletParticle2D pi = (VerletParticle2D) glyphs.get(i);
      for (int j = 0; j < i; j++) {
        VerletParticle2D pj = (VerletParticle2D) glyphs.get(j);
        // A Spring needs two particles, a resting length, and a strength
        physics.addSpring(new VerletSpring2D(pi,pj,diameter,0.01));
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
    stroke(255);
    for (int i = 0; i < glyphs.size(); i++) {
      VerletParticle2D pi = (VerletParticle2D) glyphs.get(i);
      for (int j = i+1; j < glyphs.size(); j++) {
        VerletParticle2D pj = (VerletParticle2D) glyphs.get(j);
        line(pi.x,pi.y,pj.x,pj.y);
      }
    }
  }

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
        
        // only use the first instance
        break; 
      }
    }
  }

  ArrayList getGlyphs() {
    return glyphs;
  }
}