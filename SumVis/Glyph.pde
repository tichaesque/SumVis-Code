
class Glyph extends VerletParticle2D {
  boolean spyplotted; // was the glyph highlighted in the spyplot? (after selection)  
  boolean selected;  // was the glyph selected? (used for expansion)
  boolean mouseover; // is the mouse over the glyph?
  boolean clicked;   // is the glyph clicked on? (used for handling dragging)
  float size;        // the display size of the glyph
  String glyphclass; // the type of glyph
  int glyphSize;     // the number of nodes in the glyph

  int bc_split_idx; // the index that denotes where the two sets in the bipartite core are partitioned (-1 for non-bipartite graphs)

  int[] allnodes;   // all the nodes in the glyph structure

  Glyph(Vec2D pos, float size_, String glyphclass_, int glyphSize_, int[] allnodes_) { 
    super(pos);
    clicked = false; 
    mouseover = false; 
    selected = false; 
    spyplotted = false; 

    size = size_; 
    glyphSize = glyphSize_; 

    glyphclass = glyphclass_;

    bc_split_idx = -1;

    allnodes = new int[glyphSize]; 
    arrayCopy(allnodes_, allnodes);
  }

  boolean contains(int x1, int y1) {
    return (x - size/2) <= x1 && x1 <= (x + size/2) &&
      (y - size/2) <= y1 && y1 <= (y + size/2);
  }

  void setClicked(boolean isClicked) {
    clicked = isClicked;
  }
  void setSelected(boolean isSelected) {
    selected = isSelected;
  }

  void update(float mousex, float mousey) {
    if (clicked) {
      x = mousex;
      y = mousey;
    }

    mouseover = contains(int(mousex), int(mousey));
  }

  void display() {
    String glyphName = ""; 
    if (mouseover || selected) {
      strokeWeight(2);
      stroke(360);
    } else {
      noStroke();
    }

    // deselect previous structure that was selected
    if (spyplotted && !selected) {
      plotHelper(false);
      spyplotted = false;
    }
    // select new structure
    else if (!spyplotted && selected) { 
      plotHelper(true);
      spyplotted = true;
    }

    if (foundselected && !spyplotted) {
      if (mouseover) {
        //println("true, "+ mouseoverSomething);
        plotOverlapHelper(true);
      } else if (!mouseover) {
        //println("false, "+mouseoverSomething);
        plotOverlapHelper(false);
      }
    }

    float opacity = 360; 

    /* Full cliques are represented as squares */
    if (glyphclass.equals("fc")) {
      glyphName = "Full-Clique"; 
      color fc_fill = (color(fc_hue, 66, 96)); 
      fill(fc_fill, opacity);
      rectMode(CENTER); 
      rect(x, y, size, size, cliqueRoundness);
    }
    /* Stars are represented as stars */
    else if (glyphclass.equals("st")) {
      glyphName = "Star"; 
      color st_fill = (color(st_hue, 100, 100)); 
      fill(st_fill, opacity);
      star(x, y, size*0.4, size*0.7, 5);
    }
    /* Chains are represented as rectangles */
    else if (glyphclass.equals("ch")) {
      glyphName = "Chain"; 
      color ch_fill = (color(ch_hue, 66, 80)); 
      fill(ch_fill, opacity);
      rectMode(CENTER); 
      rect(x, y, size*1.4, size*0.7, 8);
    }
    /* Bipartite cores are represented as bowties */
    else if (glyphclass.equals("bc")) {
      glyphName = "Bipartite Core"; 
      color bc_fill = (color(bc_hue, 49, 100)); 
      fill(bc_fill, opacity);
      rectMode(CENTER); 
      bc(x, y, size*0.6);
    }
    /* Near-bipartite cores are represented as bowties, but pink */
    else if (glyphclass.equals("nb")) {
      glyphName = "Near-Bipartite Core"; 
      color bc_fill = (color(bc_hue, 100, 100)); 
      fill(bc_fill, opacity);
      rectMode(CENTER); 
      bc(x, y, size*0.6);
    }

    if (mouseover || selected) {
      fill(360); 
      text(glyphName + ", size " + glyphSize, x, y-size*0.8);
    }
  }

  // function that sets the "selected" field of the spy plot points as a specified boolean value 
  void plotHelper(boolean first) {
    /* Plotter for full-cliques */
    if (glyphclass.equals("fc")) {

      for (int i = 0; i < glyphSize; i++) {
        for (int k = i+1; k < glyphSize; k++) {
          SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isFirst = first;
          SpyPlotPoints[allnodes[k]-minNodeID][allnodes[i]-minNodeID].isFirst = first;
          SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond = false;
          SpyPlotPoints[allnodes[k]-minNodeID][allnodes[i]-minNodeID].isSecond = false;

        }
      }
    }
    /* Plotter for stars */
    else if (glyphclass.equals("st")) {
      for (int i = 1; i < glyphSize; i++) {
        SpyPlotPoints[allnodes[0]-minNodeID][allnodes[i]-minNodeID].isFirst = first;
        SpyPlotPoints[allnodes[i]-minNodeID][allnodes[0]-minNodeID].isFirst = first;
        SpyPlotPoints[allnodes[0]-minNodeID][allnodes[i]-minNodeID].isSecond = false;
        SpyPlotPoints[allnodes[i]-minNodeID][allnodes[0]-minNodeID].isSecond = false;

      }
    }
    /* Plotter for chains */
    else if (glyphclass.equals("ch")) {
      for (int i = 1; i < glyphSize; i++) {
        SpyPlotPoints[allnodes[i-1]-minNodeID][allnodes[i]-minNodeID].isFirst = first;
        SpyPlotPoints[allnodes[i]-minNodeID][allnodes[i-1]-minNodeID].isFirst = first;
        SpyPlotPoints[allnodes[i-1]-minNodeID][allnodes[i]-minNodeID].isSecond = false;
        SpyPlotPoints[allnodes[i]-minNodeID][allnodes[i-1]-minNodeID].isSecond = false;

      }
    }
    /* Plotter for bipartite cores */
    else if (glyphclass.equals("bc") || glyphclass.equals("nb")) {
      for (int i = 0; i <= bc_split_idx; i++) {
        for (int k = bc_split_idx+1; k < glyphSize; k++) {
          SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isFirst = first;
          SpyPlotPoints[allnodes[k]-minNodeID][allnodes[i]-minNodeID].isFirst = first;
          SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond = false;
          SpyPlotPoints[allnodes[k]-minNodeID][allnodes[i]-minNodeID].isSecond = false;

        }
      }
    }
  }


  void plotOverlapHelper(boolean second) {
    /* Plotter for full-cliques */
    if (glyphclass.equals("fc")) {
      for (int i = 0; i < glyphSize; i++) {
        for (int k = i+1; k < glyphSize; k++) {
          if (!second && SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond) {
            if (!mouseoverSomething) {
              SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond = false;
              SpyPlotPoints[allnodes[k]-minNodeID][allnodes[i]-minNodeID].isSecond = false;
            }
          } else if (second && !SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond) {
            SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond = true;
            SpyPlotPoints[allnodes[k]-minNodeID][allnodes[i]-minNodeID].isSecond = true;
          } else if (!second && !SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond) {
            SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond = false;
            SpyPlotPoints[allnodes[k]-minNodeID][allnodes[i]-minNodeID].isSecond = false;
          }
        }
      }
    }
    /* Plotter for stars */
    else if (glyphclass.equals("st")) {
      for (int i = 1; i < glyphSize; i++) {
        if (!second && SpyPlotPoints[allnodes[0]-minNodeID][allnodes[i]-minNodeID].isSecond) {
          if (!mouseoverSomething) {
            SpyPlotPoints[allnodes[0]-minNodeID][allnodes[i]-minNodeID].isSecond = false;
            SpyPlotPoints[allnodes[i]-minNodeID][allnodes[0]-minNodeID].isSecond = false;
          }
        } else if (second && !SpyPlotPoints[allnodes[0]-minNodeID][allnodes[i]-minNodeID].isSecond) {
          SpyPlotPoints[allnodes[0]-minNodeID][allnodes[i]-minNodeID].isSecond = true;
          SpyPlotPoints[allnodes[i]-minNodeID][allnodes[0]-minNodeID].isSecond = true;
        } else if (!second && !SpyPlotPoints[allnodes[0]-minNodeID][allnodes[i]-minNodeID].isSecond) {
          SpyPlotPoints[allnodes[0]-minNodeID][allnodes[i]-minNodeID].isSecond = false;
          SpyPlotPoints[allnodes[i]-minNodeID][allnodes[0]-minNodeID].isSecond = false;
        }
      }
    }
    /* Plotter for chains */
    else if (glyphclass.equals("ch")) {
      for (int i = 1; i < glyphSize; i++) {
        if (!second && SpyPlotPoints[allnodes[0]-minNodeID][allnodes[i]-minNodeID].isSecond) {
          if (!mouseoverSomething) {
            SpyPlotPoints[allnodes[i-1]-minNodeID][allnodes[i]-minNodeID].isSecond = false;
            SpyPlotPoints[allnodes[i]-minNodeID][allnodes[i-1]-minNodeID].isSecond = false;
          }
        } else if (second && !SpyPlotPoints[allnodes[0]-minNodeID][allnodes[i]-minNodeID].isSecond) {
          SpyPlotPoints[allnodes[i-1]-minNodeID][allnodes[i]-minNodeID].isSecond = true;
          SpyPlotPoints[allnodes[i]-minNodeID][allnodes[i-1]-minNodeID].isSecond = true;
        } else if (!second && !SpyPlotPoints[allnodes[0]-minNodeID][allnodes[i]-minNodeID].isSecond) {
          SpyPlotPoints[allnodes[i-1]-minNodeID][allnodes[i]-minNodeID].isSecond = false;
          SpyPlotPoints[allnodes[i]-minNodeID][allnodes[i-1]-minNodeID].isSecond = false;
        }
      }
    }
    /* Plotter for bipartite-cores */
    if (glyphclass.equals("bc")) {
      for (int i = 0; i <= bc_split_idx; i++) {
        for (int k = bc_split_idx+1; k < glyphSize; k++) {
          if (!second && SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond) {
            if (!mouseoverSomething) {
              SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond = false;
              SpyPlotPoints[allnodes[k]-minNodeID][allnodes[i]-minNodeID].isSecond = false;
            }
          } else if (second && !SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond) {
            SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond = true;
            SpyPlotPoints[allnodes[k]-minNodeID][allnodes[i]-minNodeID].isSecond = true;
          } else if (!second && !SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond) {
            SpyPlotPoints[allnodes[i]-minNodeID][allnodes[k]-minNodeID].isSecond = false;
            SpyPlotPoints[allnodes[k]-minNodeID][allnodes[i]-minNodeID].isSecond = false;
          }
        }
      }
    }
  }

  void bc(float x, float y, float radius) {
    beginShape(TRIANGLES);
    vertex(x, y); 
    vertex(x-radius, y-radius);
    vertex(x-radius, y+radius); 
    vertex(x, y); 
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