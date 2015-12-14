// Somd code adapted from:
// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

class Cluster {

  // A cluster is a grouping of nodes
  ArrayList<Glyph> glyphs;
  // A list of all the connected pairs
  ArrayList<VerletParticle2D[]> connections;
  
  // largest number of nodes two structures have in common
  private int maxCommonNodes = 0;
  private int minCommonNodes = 0;
  private ArrayList<int[]> springs;   

  float diameter;
  
  // number of structures to be displayed onscreen
  int numStructures = 5; 
  
  Vec2D center;

  // We initialize a Cluster with a number of nodes, a diameter, and centerpoint
  Cluster(String dataset, float d, Vec2D center_) {

    // Initialize the ArrayList
    glyphs = new ArrayList();
    connections = new ArrayList<VerletParticle2D[]>();
    springs = new ArrayList<int[]>(); 

    // Set the diameter
    diameter = d;
    
    center = center_; 

    // Create the glyphs
    processStructures(dataset);
   
  }
  
  void processStructures(String dataset) {
    String[] structures = 
      loadStrings(dataset);
    
    int maxGlyphSize = 0; 
    int minGlyphSize = Integer.MAX_VALUE; 
    
    // find min/max glyph size
    for(int i = 0; i < numStructures; i++) {
      String[] glyphcomponents = split(structures[i], ' '); 
      int glyphSize = glyphcomponents.length-1; 
      
      if(glyphSize > maxGlyphSize)
        maxGlyphSize = glyphSize;
      if(glyphSize < minGlyphSize)
        minGlyphSize = glyphSize; 
    }
      
    // Processes structures
    for(int i = 0; i < numStructures; i++) {
      // The glyph class is the first symbol in the line
      String[] glyphcomponents = split(structures[i], ' '); 
      String glyphclass = glyphcomponents[0]; 
      
      int glyphSize = glyphcomponents.length-1; 
      
      float size = 30f;
      
      if(maxGlyphSize != minGlyphSize) 
        size = map(glyphSize, minGlyphSize, maxGlyphSize, 30f, 30f*(1+log(maxGlyphSize/minGlyphSize))); 
      
      Glyph g = new Glyph(center.add(Vec2D.randomVector()), size, glyphclass, glyphSize);
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
    
    // find all the connections!
    findConnections(structures); 
    
    findMinCommon(); 
    
    // add all the springs!
    drawSprings(); 
    
  }
  
  void findConnections(String[] structures) {
    // Find connections between the glyph structures
    for(int i = 0; i < numStructures; i++) {
      // need to remove commas from string before splitting
      // individual components of the current structure
      String[] currentStructure = split(structures[i], ' ');
      
      for(int j = 1; j < currentStructure.length; j++) {
        String currID1 = currentStructure[j];
        String node1ID;
        // check if there's a comma at the end and ignore
        if(currID1.charAt(currID1.length()-1) == ',') {
          node1ID = currID1.substring(0,currID1.length()-1);
        }
        else {
          node1ID = currID1; 
        }
        
        // searching within the structure list
        for(int k = i+1; k < numStructures; k++) {
          // number of nodes that the current two structures have in common
          String searchingStructure = structures[k]; 
          
          if(searchingStructure.indexOf(node1ID) != -1) { 
            updateSprings(i,k); 
          }
        }
        
      }
    }
  }
  
  void findMinCommon() {
    minCommonNodes = maxCommonNodes; 
    for(int i = 0; i < springs.size(); i++) {
      if(springs.get(i)[2] < minCommonNodes) {
        minCommonNodes = springs.get(i)[2]; 
      }
    }
  }
  
  void updateSprings(int structure1, int structure2) {
    
    boolean foundPair = false; 
    for(int i = 0; i < springs.size(); i++) {
      // if this pair already exists, update the number of common nodes
      if(springs.get(i)[0] == structure1 && springs.get(i)[1] == structure2) {
        int numCommonNodes = springs.get(i)[2]; 
        
        if(numCommonNodes+1 > maxCommonNodes) {
          maxCommonNodes = numCommonNodes; 
        }
        
        springs.get(i)[2] = numCommonNodes+1;
        foundPair = true; 
        break; 
      }
    }
    
    if(!foundPair) {
      int[] newSpring = {structure1,structure2,1};
      springs.add(newSpring); 
    }
    
  }
  
  void drawSprings() {
    println("num springs: "+springs.size());  
    
    for(int i = 0; i < springs.size(); i++) {
      int[] currSpring = springs.get(i); 
      
      VerletParticle2D pi = (VerletParticle2D) glyphs.get(currSpring[0]);
      VerletParticle2D pk = (VerletParticle2D) glyphs.get(currSpring[1]);
      float springlength = diameter; 
      
      if(maxCommonNodes != minCommonNodes) {
        springlength = map(-currSpring[2], -maxCommonNodes, -minCommonNodes, 10, diameter); 
      }
      
      springlength= 250; 
      
      physics.addSpring(new VerletSpring2D(pi,pk, springlength,0.01));
      VerletParticle2D[] newConnection = { pi, pk };
      connections.add(newConnection); 
    }
    println("num connections: "+connections.size()); 
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
    
    for (int i = 0; i < connections.size(); i++) {
      int[] currSpring = springs.get(i); 
      float springweight = map(currSpring[2], minCommonNodes, maxCommonNodes, 5, 30);
      
      VerletParticle2D c1 = (VerletParticle2D) connections.get(i)[0];
      VerletParticle2D c2 = (VerletParticle2D) connections.get(i)[1];
      
      strokeWeight(springweight); 
      stroke(360,30);
      
      line(c1.x, c1.y, c2.x, c2.y); 
      
    }
  }

  ArrayList getGlyphs() {
    return glyphs;
  }
 

 
}