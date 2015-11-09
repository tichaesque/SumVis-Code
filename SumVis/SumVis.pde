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

color bgcol = #0A2D43; 

Cluster c; 

private String dataset;

PFont bitfont;

// Clique customization
int cliqueRoundness = 3;
float fc_hue = 352; 
float st_hue = 39;
float ch_hue = 179;
float bc_hue = 276; 

void setup() {
  background(bgcol); 
  colorMode(HSB, 360, 100, 100);
  size(800,800);  
  textSize(15);
  cp5 = new ControlP5(this);
  //pixelDensity(displayDensity());
  
  bitfont = createFont("Nintendo-DS-BIOS",20,true); 
  textFont(bitfont); 
  
  // Initialize the physics
  physics=new VerletPhysics2D();
  physics.setWorldBounds(new Rect(10,10,width-20,height-20));
  
  // create graph
  Vec2D center = new Vec2D(width/2,height/2);
  dataset = "sampleGraph_top10ordered.model"; 
  c = new Cluster(dataset, 200, center);
  
  //smooth(); 
  rectMode(CENTER); 
  
  // UI stuff
  cp5.addButton("glyphOptions")
     .setLabel("Glyph Options")
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
  
  cp5.addSlider("cliqueRoundness")
     .setPosition(30,100)
     .setRange(0,7)
     .setLabel("Clique Roundness")
     ;
     
  cp5.addSlider("fc_hue")
     .setPosition(30,130)
     .setRange(0,360)
     .setLabel("Clique Hue")
     ;
}

void mouseReleased() {
  ArrayList<Glyph> glyphs = c.getGlyphs(); 
  for (Glyph g: glyphs) {
    g.setClicked(false); 
  }
}

void mousePressed() {
  ArrayList<Glyph> glyphs = c.getGlyphs(); 
  // Check to see if the mouse was clicked on the box
  for (Glyph g: glyphs) {
    if(g.contains(mouseX,mouseY)) {
      g.setClicked(true); 
      
      // only use the first instance
      break; 
    }
  }
  
}

void draw() {
  background(bgcol); 
  fill(360); 
  text("DATASET: " + dataset, 30, 30);
  
  physics.update();
  
  c.showConnections();  
  c.display();
  
}

// UI STUFF
public void controlEvent(ControlEvent theEvent) {
  //println(theEvent.getController().getName());
}

public void glyphOptions(int theValue) {
  println("a button event from glyphOptions: "+theValue);
}

public void saveScreen(int theValue) {
  saveFrame(); 
}