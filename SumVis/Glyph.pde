
class Glyph extends VerletParticle2D {
  
  boolean clicked; 
  float size; 
  String glyphclass; 
  
  //private color fc_col = #ffa500; 
  
  Glyph(Vec2D pos, float size_, String glyphclass_) { 
    super(pos);
    clicked = false; 
    
    size = size_; 

    glyphclass = glyphclass_;
    
  }
  
  boolean contains(int x1, int y1) {
    return (x - size/2) <= x1 && x1 <= (x + size/2) &&
            (y - size/2) <= y1 && y1 <= (y + size/2); 
  }
  
  void setClicked(boolean isClicked) {
    clicked = isClicked; 
  }
  
  void update(float mousex, float mousey) {
    if (clicked) {
      x = mousex;
      y = mousey; 
    }
  }
  
  void display() {
    strokeWeight(4);
    stroke(255); 
    
    /* Full cliques are represented as squares */
    if(glyphclass.equals("fc")) {
      color fc_fill = (color(fc_hue,255,255)); 
      fill(fc_fill);
      rectMode(CENTER); 
      rect(x,y,size,size,cliqueRoundness);
    }
  }
  
}