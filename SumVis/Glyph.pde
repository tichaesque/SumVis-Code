
class Glyph extends VerletParticle2D {
  
  boolean clicked; 
  float size; 
  String glyphclass; 
  int glyphSize; 
  
  //private color fc_col = #ffa500; 
  
  Glyph(Vec2D pos, float size_, String glyphclass_, int glyphSize_) { 
    super(pos);
    clicked = false; 
    
    size = size_; 
    glyphSize = glyphSize_; 

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
    //strokeWeight(4);
    //stroke(360);
    String glyphName = ""; 
    if(clicked) {
      fill(360); 
      strokeWeight(1.5);
      stroke(360);
    }
    else
      noStroke(); 
    
    float opacity = 360*.6; 
    
    /* Full cliques are represented as squares */
    if(glyphclass.equals("fc")) {
      glyphName = "Full-Clique"; 
      color fc_fill = (color(fc_hue,66,96)); 
      fill(fc_fill, opacity);
      rectMode(CENTER); 
      rect(x,y,size,size,cliqueRoundness);
    }
    /* Stars are represented as stars */
    else if(glyphclass.equals("st")) {
      glyphName = "Star"; 
      color st_fill = (color(st_hue,100,100)); 
      fill(st_fill, opacity);
      star(x,y, size*0.5, size*0.8,5); 
    }
    /* Chains are represented as rectangles */
    else if(glyphclass.equals("ch")) {
      glyphName = "Chain"; 
      color ch_fill = (color(ch_hue,66,80)); 
      fill(ch_fill, opacity);
      rectMode(CENTER); 
      rect(x,y,size*2,size,8);
    }
    /* Bipartite cores are represented as bowties */
    else if(glyphclass.equals("bc")) {
      glyphName = "Bipartite Core"; 
      color bc_fill = (color(bc_hue,49,100)); 
      fill(bc_fill, opacity);
      rectMode(CENTER); 
      bc(x,y, size);
    }
    
    if(clicked) {
      fill(360); 
      text(glyphName + ", size " + glyphSize, x,y-size*0.8); 
    }
  }
  
  void bc(float x, float y, float radius) {
    beginShape(TRIANGLES);
    vertex(x,y); 
    vertex(x-radius, y-radius);
    vertex(x-radius, y+radius); 
    vertex(x,y); 
    vertex(x+radius, y+radius);
    vertex(x+radius, y-radius); 
    endShape();
  }
  
  void star(float x, float y, float radius1, float radius2, int npoints) {
    float angle = TWO_PI / npoints;
    float halfAngle = angle/2.0;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + cos(a) * radius2;
      float sy = y + sin(a) * radius2;
      vertex(sx, sy);
      sx = x + cos(a+halfAngle) * radius1;
      sy = y + sin(a+halfAngle) * radius1;
      vertex(sx, sy);
    }
    endShape(CLOSE);
  }
  
}