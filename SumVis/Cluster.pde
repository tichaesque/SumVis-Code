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
  
  //pick top 5 structures
  //int numStructures = 5;
  
  Vec2D center;
  
  private int maxCommonNodes = 0;
  private ArrayList<float[]> springs;   

  // We initialize a Cluster with a number of nodes, a diameter, and centerpoint
  Cluster(String dataset, float d, Vec2D center_) {

    // Initialize the ArrayList
    glyphs = new ArrayList();
    connections = new ArrayList<VerletParticle2D[]>();
    springs = new ArrayList<float[]>(); 

    // Set the diameter
    diameter = d;
    
    center = center_; 

    // Create the glyphs
    processStructures(dataset);
   
  }
  
  void processStructures(String dataset) {
    String[] structures = 
      loadStrings(dataset);

    // just display all structures; for testing
    //int numStructures = structures.length;
    int numStructures = 5; 
      
    // Processes structures
    for(int i = 0; i < numStructures; i++) {
      // The glyph class is the first symbol in the line
      String glyphclass = (split(structures[i], ' '))[0]; 
      /* NEED TO ADD
        - size scaling (proportional to the number of nodes in the structure)
      */
      float size = 40f; 
      
      Glyph g = new Glyph(center.add(Vec2D.randomVector()), size, glyphclass);
      glyphs.add(g); 
      
      if(glyphclass.equals("fc")) {
        structuresFound[0]++; 
      }
      else if(glyphclass.equals("st")) {
        structuresFound[1]++; 
      }
      else if(glyphclass.equals("ch")) {
        structuresFound[2]++; 
      }
      else if(glyphclass.equals("bc")) {
        structuresFound[3]++; 
      }
      
    }
    
    // Find connections between the glyph structures
    for(int i = 0; i < numStructures; i++) {
      // need to remove commas from string before splitting
      String[] currentStructure = split(structures[i], ' ');
      
      VerletParticle2D pi = (VerletParticle2D) glyphs.get(i);
      for(int j = 1; j < currentStructure.length; j++) {
        String currID1 = currentStructure[j];
        int node1ID;
        // check if there's a comma at the end and ignore
        if(currID1.charAt(currID1.length()-1) == ',') {
          node1ID = int(currID1.substring(0,currID1.length()-1));
        }
        else {
          node1ID = int(currID1); 
        }
        
        // searching within the structure list
        for(int k = i+1; k < numStructures; k++) {
          
          String[] otherStructure = split(structures[k], ' ');
          int commonNodes = 0; 
          
          // searching the vertices within the structure
          for(int l = 1; l < otherStructure.length; l++) {
            String currID2 = otherStructure[l];
            int node2ID;
            // check if there's a comma at the end and ignore
            if(currID2.charAt(currID2.length()-1) == ',') {
              node2ID = int(currID2.substring(0,currID2.length()-1));
            }
            else {
              node2ID = int(currID2); 
            }
            
            if(node1ID == node2ID) {
              commonNodes++; 
              /*
              VerletParticle2D pi = (VerletParticle2D) glyphs.get(i);
              VerletParticle2D pk = (VerletParticle2D) glyphs.get(k);
              
              physics.addSpring(new VerletSpring2D(pi,pk,diameter,0.01));
              VerletParticle2D[] newConnection = { pi, pk };
              connections.add(newConnection); 
              
              break; 
              */
            }
          }
          
          if(commonNodes > maxCommonNodes) {
            maxCommonNodes = commonNodes; 
          }
          
          if(commonNodes > 0) {
            float[] newSpring = {(float) i, (float) k, commonNodes}; 
            springs.add(newSpring); 
          }
          
          
        }
      }
      
    }
    
    // draw all the springs!
    for(int i = 0; i < springs.size(); i++) {
      float[] currSpring = springs.get(i); 
      
      VerletParticle2D pi = (VerletParticle2D) glyphs.get((int)currSpring[0]);
      VerletParticle2D pk = (VerletParticle2D) glyphs.get((int)currSpring[1]);
      float springlength; 
      
      springlength = map(currSpring[2], 0, maxCommonNodes, diameter/3, diameter); 
      
      physics.addSpring(new VerletSpring2D(pi,pk, springlength,0.01));
      VerletParticle2D[] newConnection = { pi, pk };
      connections.add(newConnection); 
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
    stroke(360); 
    
    for (int i = 0; i < connections.size(); i++) {
      VerletParticle2D c1 = (VerletParticle2D) connections.get(i)[0];
      VerletParticle2D c2 = (VerletParticle2D) connections.get(i)[1];
      
      line(c1.x,c1.y,c2.x,c2.y);
    }
  }

  ArrayList getGlyphs() {
    return glyphs;
  }
}