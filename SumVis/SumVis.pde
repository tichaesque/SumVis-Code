/* 
 * SumVis: An Interactive Summary and Visualization Tool for Large-Scale Graphs 
 * by Ticha Sethapakdi
 * 
 * Some code adapted from Processing examples and 
 * Daniel Shiffman's The Nature of Code
 */

import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import controlP5.*; 

import g4p_controls.*;

/******* FOR THE MAIN VISUALIZATION *******/
ControlP5 cp5;

// Reference to physics world
VerletPhysics2D physics;

color bgcol = #0e2f44; 

// the main cluster
Cluster c; 

// the cluster for an expanded glyph
Cluster e; 

// name of the input file for VOG's output
private String dataset;
// the name of the input file used to create the spy plot
String spyplotdata; 

PFont bitfont;

// Clique customization
int cliqueRoundness = 0;
float fc_hue = 352; 
float st_hue = 39;
float ch_hue = 179;
float bc_hue = 276; 
float node_hue = 87.27;

/***** UI handling *****/
GWindow[] window;

controlP5.Slider[] customization = new controlP5.Slider[2];
boolean glyphOptionsVisible = false; 

controlP5.Button expandGlyphButton;
controlP5.Button returnButton; 

controlP5.Button hairballButton; 

// Distinct structures found by VOG 
// (used by the displayed list in the bottom-right hand corner)
// Organized as: {Full Cliques, Stars, Chains, Bipartite Cores, Near-Bipartite Cores}
int[] structuresFound = new int[5]; 

// variable that determine whether we are looking at an expanded glyph
boolean isExpanded = false; 

// index that keeps track of where we are in the structure file
int structureFilePos = 0; 
int newStructureFilePos = 0; 

int datasetlen; 

boolean foundselected; 

Hairball hairball; 

boolean showingHairball = false;
boolean hairballRendered = false;
boolean spyPlotRendered = false;

void setup() {
  //background(bgcol); 
  colorMode(HSB, 360, 100, 100);
  size(1200, 700);  
  textSize(15);
  cp5 = new ControlP5(this);
  pixelDensity(displayDensity());

  bitfont = loadFont("Nintendo-DS-BIOS-48.vlw"); 
  textFont(bitfont, 20); 

  theSpyPlot = new SpyPlot(); 
  theSpyPlot.prepareSpyPlot();

  hairball = new Hairball(spyplotdata, 200, new Vec2D(width*0.25, height/2));

  prepareVisualization(); 

  rectMode(CENTER); 

  smooth();
}

void draw() {
  makeVisualization(); 

  if (showingHairball && !hairballRendered) {
    hairball.display();
  } else if (!showingHairball && !spyPlotRendered) {
    theSpyPlot.display();
  }

  drawUI();
}

void drawUI() {
  textAlign(LEFT);
  textSize(18);  
  fill(#ffffff);

  // scrolling rectangle   
  float rectPosX = map(newStructureFilePos, 0, datasetlen-5, 630, 730);
  rectMode(CENTER);

  text("Showing structures " + newStructureFilePos + "-" + int(newStructureFilePos+4), 628, 600);

  if (newStructureFilePos == 0) {
    fill(#ffffff); 
    text("^scroll for more", rectPosX-2, 655); 
    fill(#ffffff);
  } else
    fill(#3399ff);

  rect(rectPosX, 624, 4, 25);
}

void prepareVisualization() {
  // Initialize the physics
  physics=new VerletPhysics2D();
  physics.setWorldBounds(new Rect(10, 10, width-20, height-20));

  physics.clear(); 

  String path = dataPath("");
  File[] files = listFiles(path);
  for (int i = 0; i < files.length; i++) { 
    String filename = files[i].getName();

    // use the first model file that is found in the data directory as input
    if (filename.endsWith(".model")) {
      dataset = filename; 
      break;
    }
  }

  c = new Cluster(dataset, 250, new Vec2D(width*0.75, height/2)); 

  datasetlen = loadStrings(dataset).length; 

  createUI();
}

void makeVisualization() {
  //background(bgcol);
  rectMode(CORNER); 
  fill(bgcol); 
  rect(width/2, 0, width/2, height); 
  rectMode(CENTER); 

  textSize(20);
  fill(360); 
  text("DATASET: " + dataset, 630, 30);

  physics.update();

  c.showConnections();  
  c.display(); 

  String foundStructures; 
  int numDistinctStructures = 0; 

  // is a part of the hairball currently highlighted?
  boolean hairballHighlighted = false;

  if (newStructureFilePos != structureFilePos) {
    for (int i = 0; i < plotsize; i++) {
      for (int j = 0; j < plotsize; j++) {
        if (SpyPlotPoints[i][j].isFirst) {
          hairballHighlighted = true;
        }
        SpyPlotPoints[i][j].isFirst = false;
        SpyPlotPoints[i][j].isSecond = false;
      }
    }

    // refresh hairball if we're moving along the file
    if (hairballHighlighted) {
      hairballRendered = false;
      spyPlotRendered = false;
    }

    foundselected = false;
    structureFilePos = newStructureFilePos; 
    initializeGraph();
  }

  // Text box showing structures found

  foundStructures = "STRUCTURES DISPLAYED:\n"; 
  for (int i = 0; i < structuresFound.length; i++) {
    int structurecount = structuresFound[i];

    if (structurecount > 0) {
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
      case 4:
        foundStructures += "  Near-Bipartite  Core"; 
        break;
      }

      if (structurecount > 1) {
        foundStructures += "s";
      }

      foundStructures += "\n";
    }
  }

  fill(#071722, 200); 
  noStroke(); 
  rectMode(CORNERS); 
  // corners of rectangles
  float upperleftcorner_x = width*0.7; 
  float upperleftcorner_y =  height-63-25*numDistinctStructures; 
  float bottomrightcorner_x = width-30; 
  float bottomrightcorner_y = height-30; 
  rect(upperleftcorner_x, upperleftcorner_y, bottomrightcorner_x, bottomrightcorner_y, 3); 

  fill(360); 
  text(foundStructures, 
    upperleftcorner_x + 10, upperleftcorner_y + 10, 
    bottomrightcorner_x-10, bottomrightcorner_y-10);
}

public void initializeGraph() {
  // the new cluster center
  Vec2D center = new Vec2D(width*.75, height/2);

  c = new Cluster(dataset, 250, center);

  isExpanded = false; 
  returnButton.hide();
}

void createUI() {
  // UI BUTTONS!!
  cp5.addButton("saveScreen")
    .setLabel("Save Screen")
    .setPosition(width*0.55, 50)
    .setSize(100, 30)
    .setColorBackground(#061b28)
    .setColorForeground(#ff8c19)
    ;

  hairballButton = cp5.addButton("showHairball")
    .setLabel("Show Hairball")
    .setPosition(width*0.2, 50)
    .setSize(100, 30)
    .setColorBackground(#061b28)
    .setColorForeground(#ff8c19)
    ;

  returnButton = cp5.addButton("returnToGraph")
    .setLabel("Go Back")
    .setPosition(970, 50)
    .setSize(110, 30)
    .setColorBackground(#061b28)
    .setColorForeground(#ff8c19)
    .hide(); 
  ;

  // Position in file slider
  if (datasetlen > 5) {
    cp5.addSlider("newStructureFilePos")
      .setPosition(630, 620)
      .setRange(0, datasetlen-5)
      .setSize(100, 10) 
      .setColorBackground(#ffffff) 
      .setColorForeground(#3399ff)
      .setColorValue(#ffffff)
      .setColorActive(#3399ff)
      .setLabel(" ")
      ;
  }


  // UI SLIDERS!!
  customization[0] = cp5.addSlider("cliqueRoundness")
    .setPosition(630, 100)
    .setRange(0, 7)
    .setLabel("Clique Roundness")
    .setVisible(false)
    ;

  customization[1] = cp5.addSlider("fc_hue")
    .setPosition(630, 130)
    .setRange(0, 360)
    .setLabel("Clique Hue")
    .setVisible(false)
    ;
}

void mouseReleased() {
  // check if user has clicked on the show hairball button
  if (!((width*0.2 <= mouseX && mouseX <= width*0.2+100) && 
    (50 <= mouseY && mouseY <=50+30))) {
    ArrayList<Glyph> glyphs = c.getGlyphs(); 
    foundselected = false; 

    for (Glyph g : glyphs) {
      if (g.clicked) {
        g.setSelected(true);  

        foundselected = true;
      } else {
        g.setSelected(false);
      }

      g.setClicked(false);
    }
    
    spyPlotRendered = false;
  }
}

void mousePressed() {
  ArrayList<Glyph> glyphs = c.getGlyphs(); 
  // Check to see if the mouse was clicked on the box
  for (Glyph g : glyphs) {
    if (g.contains(mouseX, mouseY)) {
      g.setClicked(true); 

      break;
    }
  }
}

// UI STUFF
public void next5(int theValue) {

  // ADJUST THIS TO LENGTH OF THE FILE
  if (structureFilePos < datasetlen-5) {
    structureFilePos++; 

    // the new cluster center
    Vec2D center = new Vec2D(width/2, height/2);

    c = new Cluster(dataset, 250, center);

    isExpanded = false; 
    returnButton.hide();
  }
}

public void previous5(int theValue) {
  if (structureFilePos > 0) {
    structureFilePos--; 

    // the new cluster center
    Vec2D center = new Vec2D(width/2, height/2);

    c = new Cluster(dataset, 250, center);

    isExpanded = false; 
    returnButton.hide();
  }
}

public void glyphOptions(int theValue) {
  if (glyphOptionsVisible) {
    for (int i = 0; i < customization.length; i++) {
      customization[i].hide();
    }
    glyphOptionsVisible = false;
  } else {
    for (int i = 0; i < customization.length; i++) {
      customization[i].show();
    }
    glyphOptionsVisible = true;
  }
}

public void saveScreen(int theValue) {
  saveFrame();
}

public void showHairball(int theValue) {
  showingHairball = !showingHairball;

  if (showingHairball) {
    hairballButton.setLabel("Show spy plot");
    hairballRendered = false;
  } else {
    hairballButton.setLabel("Show hairball");
    spyPlotRendered = false;
  }
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