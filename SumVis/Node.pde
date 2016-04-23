// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Force directed graph
// Heavily based on: http://code.google.com/p/fidgen/

// Notice how we are using inheritance here!
class Node extends VerletParticle2D {
  
  boolean isSelected = false; 

  Node(Vec2D pos) {
    super(pos);
  }

}