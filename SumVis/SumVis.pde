// SumVis by Ticha Sethapakdi
// Some code adapted from Processing examples and 
// Daniel Shiffman's The Nature of Code 

import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import controlP5.*;

ControlP5 cp5;

// Reference to physics world
VerletPhysics2D physics;

color bgcol = #0e2f44; 

// the main cluster
Cluster c; 

// the cluster for an expanded glyph
Cluster e; 

private String dataset;

PFont bitfont;

// Clique customization
int cliqueRoundness = 0;
float fc_hue = 352; 
float st_hue = 39;
float ch_hue = 179;
float bc_hue = 276; 
float node_hue = 87.27;

// UI handling
controlP5.Slider[] customization = new controlP5.Slider[2];
boolean glyphOptionsVisible = false; 

controlP5.Button expandGlyphButton;
controlP5.Button returnButton; 

// Number of structures found by VOG
// Organized as: {Full Cliques, Stars, Chains, Bipartite Cores}
int[] structuresFound = new int[4]; 

// variable that determine whether we are looking at an expanded glyph
boolean isExpanded = false; 

void setup() {
  background(bgcol); 
  colorMode(HSB, 360, 100, 100);
  size(700,700);  
  textSize(15);
  cp5 = new ControlP5(this);
  pixelDensity(displayDensity());
  
  bitfont = createFont("Nintendo-DS-BIOS",20,true); 
  textFont(bitfont); 
  
  // Initialize the physics
  physics=new VerletPhysics2D();
  physics.setWorldBounds(new Rect(10,10,width-20,height-20));
  
  // create graph
  Vec2D center = new Vec2D(width/2,height/2);
  
  String path = dataPath("");
  File[] files = listFiles(path);
  for(int i = 0; i < files.length; i++) { 
    String filename = files[i].getName();
    
    if(filename.endsWith(".model")) {
      dataset = filename; 
      break; 
    }
  }
  
  createUI(); 
  
  c = new Cluster(dataset, 250, center, true);
  
  rectMode(CENTER); 
  
  smooth(); 
}

void draw() {
  background(bgcol); 
  fill(360); 
  text("DATASET: " + dataset, 30, 30);
  
  physics.update();
  
  c.showConnections();  
  c.display();
  String foundStructures; 
  int numDistinctStructures = 0; 
  
  // Text box showing structures found
  if(!isExpanded) {
    foundStructures = "STRUCTURES:\n"; 
    
    for(int i = 0; i < structuresFound.length; i++) {
      int structurecount = structuresFound[i];
      
      if(structurecount > 0) {
        foundStructures += structurecount; 
        numDistinctStructures++; 
        
        switch(i) {
          case 0:
            foundStructures += "  Full  Clique"; 
            break;
           case 1:
            foundStructures += "  Star"; 
            break;
           case 2:
            foundStructures += "  Chain"; 
            break;
           case 3:
            foundStructures += "  Bipartite  Core"; 
            break;
        }
        
        if(structurecount > 1) {
          foundStructures += "s"; 
        }
        
        foundStructures += "\n"; 
      }
    }
  }
  else {
    foundStructures = "Showing top 5 nodes in the expanded structure."; 
    numDistinctStructures = 2; 
  }
  
  fill(#071722, 200); 
  noStroke(); 
  rectMode(CORNERS); 
  // corners of rectangles
  float corner1 = width*0.75; 
  float corner2 =  height-63-25*numDistinctStructures; 
  float corner3 = width-30; 
  float corner4 = height-30; 
  rect(corner1, corner2, corner3, corner4, 3); 
  
  fill(360); 
  text(foundStructures, corner1 + 10, corner2 + 10,corner3-10, corner4-10);
  
}

void createUI() {
  // UI BUTTONS!!
  cp5.addButton("glyphOptions")
     .setLabel("Customize")
     .setPosition(30,50)
     .setSize(100,30)
     .setColorBackground(#061b28)
     .setColorForeground(#ff8c19)
     ;
     
  cp5.addButton("saveScreen")
     .setLabel("Save Screen")
     .setPosition(200,50)
     .setSize(100,30)
     .setColorBackground(#061b28)
     .setColorForeground(#ff8c19)
     ;
     
  expandGlyphButton = cp5.addButton("expandGlyph")
     .setLabel("Expand Glyph")
     .setPosition(370,50)
     .setSize(110,30)
     .setColorBackground(#061b28)
     .setColorForeground(#ff8c19)
     .hide(); 
     ;
     
  returnButton = cp5.addButton("returnToGraph")
     .setLabel("Go Back")
     .setPosition(370,50)
     .setSize(110,30)
     .setColorBackground(#061b28)
     .setColorForeground(#ff8c19)
     .hide(); 
     ;
  
  // UI SLIDERS!!
  customization[0] = cp5.addSlider("cliqueRoundness")
     .setPosition(30,100)
     .setRange(0,7)
     .setLabel("Clique Roundness")
     .setVisible(false)
     ;
     
  customization[1] = cp5.addSlider("fc_hue")
     .setPosition(30,130)
     .setRange(0,360)
     .setLabel("Clique Hue")
     .setVisible(false)
     ;
}

void mouseReleased() {
  ArrayList<Glyph> glyphs = c.getGlyphs(); 
  boolean foundselected = false; 
  
  for (Glyph g: glyphs) {
    if(g.clicked) {
      g.setSelected(true); 
      
      if(!isExpanded)
        expandGlyphButton.show();
      
      foundselected = true; 
    }
    else {
      g.setSelected(false); 
    }
    
    g.setClicked(false); 
  }
  
  if(!foundselected) 
    expandGlyphButton.hide();
}

void mousePressed() {
  ArrayList<Glyph> glyphs = c.getGlyphs(); 
  // Check to see if the mouse was clicked on the box
  for (Glyph g: glyphs) {
    if(g.contains(mouseX,mouseY)) {
      g.setClicked(true); 
      break; 
    }
    
  }
  
}

// UI STUFF
public void expandGlyph(int theValue) {
  ArrayList<Glyph> glyphs = c.getGlyphs(); 
  for (Glyph g: glyphs) {
    if(g.selected) {
      String glyphEncoding = g.glyphclass;
      
      for(int i = 0; i < g.top5nodes.length; i++) {
        glyphEncoding += " " + g.top5nodes[i]; 
      }
      
      println(glyphEncoding); 
      
      // the new cluster center
      Vec2D center = new Vec2D(width/2,height/2);
      
      // it's bad practice to reassign references to allocated objects all the time,
      // but I can't think of a cleaner way around this 
      // hopefully the garbage collector is active enough
      c = new Cluster(glyphEncoding, 200, center, false);
      
      break; 
    }
  }
  
  isExpanded = true; 
  returnButton.show();
  
}

public void returnToGraph(int theValue) {
  
  // the new cluster center
  Vec2D center = new Vec2D(width/2,height/2);
  
  c = new Cluster(dataset, 250, center, true);
  
  isExpanded = false; 
  returnButton.hide();
}

public void glyphOptions(int theValue) {
  if(glyphOptionsVisible) {
    for (int i = 0; i < customization.length; i++) {
      customization[i].hide(); 
    }
    glyphOptionsVisible = false; 
  }
  
  else {
    for (int i = 0; i < customization.length; i++) {
      customization[i].show(); 
    }
    glyphOptionsVisible = true; 
  }
  
}

public void saveScreen(int theValue) {
  saveFrame(); 
}

//taken from http://processing.org/learning/topics/directorylist.html
File[] listFiles(String dir) {
 File file = new File(dir);
 if (file.isDirectory()) {
   File[] files = file.listFiles();
   return files;
 } else {
   // If it's not a directory
   return null;
 }
}