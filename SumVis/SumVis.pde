import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

// Reference to physics world
VerletPhysics2D physics;

// A list of cluster objects
//ArrayList clusters;

color bgcol = #0A2D43; 
//String dataset; 

Cluster c; 

private String dataset = "cliqueStarClique_top10ordered.model"; 

void setup() {
  background(bgcol); 
  textSize(15);
  
  // Initialize the physics
  physics=new VerletPhysics2D();
  physics.setWorldBounds(new Rect(10,10,width-20,height-20));
  
  // create graph
  Vec2D center = new Vec2D(width/2,height/2);
  String dataset = "cliqueStarClique_top10ordered.model"; 
  c = new Cluster(dataset, 200, center);
  
  size(500,500); 
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
}

void draw() {
  background(bgcol); 
  fill(255); 
  text("Dataset: " + dataset, 30, 30);
  
  physics.update();
  
  c.showConnections();  
  c.display();
  
}