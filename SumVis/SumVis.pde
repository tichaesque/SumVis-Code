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

void setup() {
  background(bgcol); 
  size(800,800);  
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
  dataset = "cliqueStarClique_top10ordered.model"; 
  c = new Cluster(dataset, 200, center);
  
  smooth(); 
  rectMode(CENTER); 
  
  cp5.addButton("Glyph Options")
     .setValue(0)
     .setPosition(30,50)
     .setSize(100,30)
     .setColorBackground(#061b28)
     .setColorForeground(#ff8c19)
     ;
  
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
}

// function colorA will receive changes from 
// controller with name colorA
public void colorA(int theValue) {
  println("a button event from colorA: "+theValue);
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
  fill(255); 
  text("DATASET: " + dataset, 30, 30);
  
  physics.update();
  
  c.showConnections();  
  c.display();
  
}

boolean overRect(float x, float y, float w, float h)  { 
  return ((x-w/2) <= mouseX && mouseX <= (x+w/2) && 
      (y-h/2) <= mouseY && mouseY <= (y+h/2));
}