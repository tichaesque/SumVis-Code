// Some code adapted from:
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
  
  // springs stored as {glyph1ID, glyph2ID, # of connections}
  private ArrayList<int[]> springs;   
  

  float diameter;
  
  // number to be displayed onscreen
  int numStructures = 5; 
  
  Vec2D center;

  // We initialize a Cluster with a number of nodes, a diameter, and centerpoint
  Cluster(String dataset, float d, Vec2D center_, boolean fullGraph) {
    // Initialize structuresFound
    for(int i = 0; i < structuresFound.length; i++) {
      structuresFound[i] = 0; 
    }
  
    // Initialize the ArrayList
    glyphs = new ArrayList();
    connections = new ArrayList<VerletParticle2D[]>();
    springs = new ArrayList<int[]>(); 

    // Set the diameter
    diameter = d;
    
    center = center_; 

    // Create the glyphs
    // we're drawing the full graph, so we need to process everything!
    if(fullGraph)
      processStructures(dataset);
      
    // otherwise we're only expanding a glyph, which requires different handling
    else
      processSingleStructure(dataset);
    
  }
  
  // Expanding a glyph
  void processSingleStructure(String dataset) {
    
    String[] glyphcomponents = split(dataset, ' ');
    
    String glyphclass = glyphcomponents[0]; 
    
    for(int i = 1; i < glyphcomponents.length; i++) {
      
      if(int(glyphcomponents[i]) != 0) {
        
        // special dummy array used in expansion
        int [] blank = {-1, -1,-1,-1,-1}; 
        
        Glyph g = new Glyph(center.add(Vec2D.randomVector()), 30, "none", int(glyphcomponents[i]), blank);
        glyphs.add(g); 
      }
    }
    
    if(glyphclass.equals("fc")) {
      // indices for nodes are off by one
      for(int i = 1; i < glyphcomponents.length-1; i++) {
        for(int k = i+1; k < glyphcomponents.length; k++) {
          if(int(glyphcomponents[k]) != 0) {
            int[] newSpring = {i-1,k-1,1};
            springs.add(newSpring); 
          }
          
        }
      }
      
    }
    else if(glyphclass.equals("st")) {
      for(int k = 2; k < glyphcomponents.length; k++) {
        if(int(glyphcomponents[k]) != 0) {
          int[] newSpring = {0,k-1,1};
          springs.add(newSpring); 
        }
      }
      
    }
    
    drawSprings(); 
    
  }
  
  void processStructures(String dataset) {
    String[] structures = loadStrings(dataset);
    
    int totalstructures = structures.length; 
    
    // need to take the minimum of the two values in the case that
    // the number of structures found by VOG is less than 5
    numStructures = min(totalstructures,numStructures); 
    
    int maxGlyphSize = 0; 
    int minGlyphSize = Integer.MAX_VALUE; 
    
    // find min/max glyph size
    for(int i = structureFilePos; i < structureFilePos+numStructures; i++) {
      if(i >= totalstructures) break; 
      
      String[] glyphcomponents = split(structures[i], ' '); 
      int glyphSize = glyphcomponents.length-1; 
      
      if(glyphSize > maxGlyphSize)
        maxGlyphSize = glyphSize;
      if(glyphSize < minGlyphSize)
        minGlyphSize = glyphSize; 
    }
    
    
    // Processes structures
    for(int i = structureFilePos; i < structureFilePos+numStructures; i++) {
      if(i >= totalstructures) break; 
      
      String[] glyphcomponents = split(structures[i], ' ');
      
      // The glyph class is the first symbol in the line
      String glyphclass = glyphcomponents[0]; 
      
      int glyphSize = glyphcomponents.length-1; 
      
      float size = 30f;
      
      if(maxGlyphSize != minGlyphSize) 
        size = map(glyphSize, minGlyphSize, maxGlyphSize, 30f, 30f*(1+log(maxGlyphSize/minGlyphSize)));
        
      // save the structure's components, to be used in the expansion phase
      int[] top5nodes = new int[5]; 
      for(int j = 1; j < min(6, glyphcomponents.length); j++) {
        // remove comma at the end, if it exists
        if(glyphcomponents[j].charAt(glyphcomponents[j].length()-1) == ',') {
          glyphcomponents[j] = glyphcomponents[j].substring(0,glyphcomponents[j].length()-1);
        }
        
        top5nodes[j-1] = int(glyphcomponents[j]); 
      }
      
      Glyph g = new Glyph(center.add(Vec2D.randomVector()), size, glyphclass, glyphSize, top5nodes);
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
      else if(glyphclass.equals("nb")) {
        structuresFound[4]++; 
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
    for(int i = structureFilePos; i < structureFilePos+numStructures; i++) {
      // need to remove commas from string before splitting
      // individual components of the current structure
      String[] currentStructure = split(structures[i], ' ');
      
      // start from 1 because we're skipping over the structure name
      for(int j = 1; j < currentStructure.length; j++) {
        // look at IDs within a structure
        String currID1 = currentStructure[j];
        String node1ID;
        // check if there's a comma at the end and ignore
        if(currID1.charAt(currID1.length()-1) == ',') {
          node1ID = currID1.substring(0,currID1.length()-1);
        }
        else {
          node1ID = currID1; 
        }
        
        // check other structures for whether this ID appears again 
        // k is the index into the list of structures
        // it represents which structure we're searching in
        for(int k = i+1; k < structureFilePos+numStructures; k++) {
          // number of nodes that the current two structures have in common
          //String searchingStructure = structures[k];
          String[] searchingStructure = split(structures[k], ' ');
          
          for(int l = 0; l < searchingStructure.length; l++) {
            String currnodeID = searchingStructure[l]; 
            if(currnodeID.charAt(currnodeID.length()-1) == ',') {
              searchingStructure[l] = currnodeID.substring(0,currnodeID.length()-1);
            }
            
            if(node1ID.equals(searchingStructure[l])) {
              updateSprings(i - structureFilePos,k - structureFilePos); 
              break; 
            }
            
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
    for(int i = 0; i < springs.size(); i++) {
      int[] currSpring = springs.get(i); 
      
      VerletParticle2D pi = (VerletParticle2D) glyphs.get(currSpring[0]);
      VerletParticle2D pk = (VerletParticle2D) glyphs.get(currSpring[1]);
      float springlength = diameter; 
      
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
    for (int i = 0; i < connections.size(); i++) {
      int[] currSpring = springs.get(i); 
      float springweight = 2; 
      
      if(minCommonNodes < maxCommonNodes)
        springweight = map(currSpring[2], minCommonNodes, maxCommonNodes, 10f, 10f*(1+log(maxCommonNodes/minCommonNodes)));
      
      VerletParticle2D c1 = (VerletParticle2D) connections.get(i)[0];
      VerletParticle2D c2 = (VerletParticle2D) connections.get(i)[1];
      
      if(!isExpanded) {
        strokeWeight(springweight); 
        stroke(360,30);
      }
      
      if(isExpanded) {
        strokeWeight(1); 
        stroke(360);
      }
      
      line(c1.x, c1.y, c2.x, c2.y); 
      
    }
  }

  ArrayList getGlyphs() {
    return glyphs;
  }
 

 
}