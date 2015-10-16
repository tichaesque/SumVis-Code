// SumVis by Ticha Sethapakdi
// Some code adapted from Processing examples and 
// Daniel Shiffman's The Nature of Code 

import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

// Reference to physics world
VerletPhysics2D physics;

color bgcol = #0A2D43; 

Cluster c; 

private String dataset;
private float glyphOptionsX; 
private float glyphOptionsY; 
private float glyphOptionsW;
private float glyphOptionsH; 
private boolean overOptions; 

void setup() {
  background(bgcol); 
  textSize(15);
  
  // Initialize the physics
  physics=new VerletPhysics2D();
  physics.setWorldBounds(new Rect(10,10,width-20,height-20));
  
  // create graph
  Vec2D center = new Vec2D(width/2,height/2);
  dataset = "cliqueStarClique_top10ordered.model"; 
  c = new Cluster(dataset, 200, center);
  
  glyphOptionsX = width-110; 
  glyphOptionsY = height*0.85+55; 
  glyphOptionsW = 120; 
  glyphOptionsH = 40; 
  
  size(800,800); 
  smooth(); 
  rectMode(CENTER); 
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
  
  if(overOptions) {
    println("clicked options"); 
  }
}

void glyphOptionsButton() {
  noStroke(); 
  if(overOptions) {
    fill(#536c7b); 
  }
  else {
    fill(#061b28); 
  }
  rect(glyphOptionsX, glyphOptionsY, glyphOptionsW, glyphOptionsH, 5);
  fill(#f0f0f0); 
  text("Glyph Options", width-102, height*0.85+70, 120, 55);
}

void draw() {
  update(mouseX, mouseY); 
  background(bgcol); 
  fill(255); 
  text("Dataset: " + dataset, 30, 30);
  glyphOptionsButton();
  
  physics.update();
  
  c.showConnections();  
  c.display();
  
}

void update(float x, float y) {
  if(overRect(glyphOptionsX, glyphOptionsY, glyphOptionsW, glyphOptionsH)) {
    overOptions = true;
  }
  else {
    overOptions = false;
  }
}

boolean overRect(float x, float y, float w, float h)  { 
  return ((x-w/2) <= mouseX && mouseX <= (x+w/2) && 
      (y-h/2) <= mouseY && mouseY <= (y+h/2));
}