class Planet {
  XY xy;
  float r;
  float rot;
  float a;
  float f;
  float t = 0;
  float T;
  
  Planet(float x1, float y1, float r1, float rot1, float a1, float f1) {
    xy = new XY(x1, y1);
    r = r1;
    rot = rot1;
    a = a1;
    f = f1;
    T = sqrt(k * pow(a, 3));
  }
}

class XY {
  float x = 0;
  float y = 0;
  XY(float x1, float y1) {
    x = x1;
    y = y1;
  }
  
  float getX() {
    return x;
  }
  
  float getY() {
    return y;
  }
}

class SolarSystem {
  float sunX;
  float sunY;
  float sunDiam;
  Planet[] planets;
  
  SolarSystem(float x, float y, float d, Planet[] p) {
    sunX = x;
    sunY = y;
    sunDiam = d;
    planets = p;
  }
}


XY CalculateNextPosition(Planet planet) {
  float E = CalculateE(planet);
  float x = -planet.a * (cos(E) - planet.f);
  float y = -planet.a * sqrt(1 - pow(planet.f, 2)) * sin(E);
  return new XY(x, y);
}

float CalculateE(Planet planet) {
  if (planet.t > planet.T) {
    planet.t = 0;
  }
  float M = (2 * pi * planet.t)/planet.T;
  float E = pi;
  for (int i = 0; i < 5; i++) {
    E = E - (E - planet.f * sin(E) - M)/(1 - planet.f * cos(E));
  }
  return E;
}

XY state1 = new XY(0, 0);
XY state2 = new XY(0, 0);
float radius = 0;
int state = 0;
float newX = 0;
float newB = 0;
float newR = 0;
float newRot = 0;
float newA = 0;
float newF = 0;

float pi = 3.1415;
int t = 0;
float k = 4.2;
Planet[] p = null;
SolarSystem sol = new SolarSystem(500, 500, 50, p);

Button b1 = new Button(800, 10, 80, 50);

void setup() {
  size(900, 900);
  stroke(255, 255, 255);
  strokeWeight(3);
  
  sol.planets = new Planet[]{ new Planet(100, 0, 20, 0, 68, 0.1), 
                              new Planet(200, 0, 40, 2, 240, 0.2), 
                              new Planet(10, 0, 10, 1, 200, 0.8) };
}

void draw() {
  background(0, 0, 0);
  fill(0, 0, 0, 0);

  //Draw sun
  ellipse(sol.sunX, sol.sunY, sol.sunDiam, sol.sunDiam);
  
  //Draw planet paths
  if (sol.planets != null) {
    for (int i = 0; i < sol.planets.length; i++) {
      Planet p = sol.planets[i];
      float b = p.a * sqrt(1 - pow(p.f, 2));
      float c = sqrt(pow(p.a, 2) - pow(b, 2));
      pushMatrix();    
      translate(sol.sunX, sol.sunY);
      //float rotate = sol.planets[i].rot;
      rotate(sol.planets[i].rot);
      ellipse(c, 0, 2 * p.a, 2 * b);
      popMatrix();
      
      //Increment time
      p.t += 3;
    }
  }
  
  //Draw planets
  fill(0, 0, 0);
  if (sol.planets != null) {
    for (int i = 0; i < sol.planets.length; i++) {
      XY newPos = CalculateNextPosition(sol.planets[i]);
      sol.planets[i].xy = newPos;
      
      pushMatrix();    
      translate(sol.sunX, sol.sunY);
      rotate(sol.planets[i].rot);
      ellipse(newPos.x, newPos.y, sol.planets[i].r, sol.planets[i].r);
      popMatrix();
    }
  }
  
  //Draw inital circle
  if (state == 1) {
    float diam = 2 * sqrt(pow((sol.sunX - mouseX), 2) + pow((sol.sunY - mouseY), 2));
    if (diam < sol.sunDiam) {
      diam = sol.sunDiam;
    }
    fill(0, 0, 0, 0);
    ellipse(sol.sunX, sol.sunY, diam, diam);
    radius = diam / 2;
  }
  //Turn orbit into ellipse
  else if (state == 2) {
    float theta = atan((mouseY - sol.sunY)/(mouseX - sol.sunX));
    if (mouseX < sol.sunX) {
      theta = theta + pi;
    }
    float dist = sqrt(pow((mouseX - sol.sunX), 2) + pow((mouseY - sol.sunY), 2));
    if (dist < sol.sunDiam / 2.0) {
      dist = sol.sunDiam / 2.0;
    }
    float b = sqrt(pow((radius + dist)/2, 2) - pow((dist + radius)/2 - radius, 2));
    
    fill(0, 0, 0, 0);
    pushMatrix();    
    translate(sol.sunX, sol.sunY);
    rotate(theta);
    ellipse((dist - radius)/2, 0, radius + dist, 2 * b);
    popMatrix();
    newX = (dist - radius)/2;
    newB = b;
    newRot = theta;
    newA = (radius + dist)/2;
    newF = sqrt(1 - (pow(b, 2)/pow(newA, 2)));
    //state2 = new XY(mouseX, mouseY);
    state2 = new XY(sol.sunX + ((dist - radius)/2 + (radius + dist)/2) * cos(theta), 
    sol.sunY + ((dist - radius)/2 + (radius + dist)/2) * sin(theta));
  }
  //Create the planet
  else if (state == 3) {
    fill(0, 0, 0, 0);
    pushMatrix();    
    translate(sol.sunX, sol.sunY);
    rotate(newRot);
    ellipse(newX, 0, 2 * newA, 2 * newB);
    popMatrix();
    
    fill(0, 0, 0);
    float r = 2 * sqrt(pow((state2.x - mouseX), 2) + pow((state2.y - mouseY), 2));
    ellipse(state2.x, state2.y, r, r);
    newR = r;
  }
  
  b1.update();
  b1.display();
  
  fill(0, 0, 0);
  textSize(25);
  text("Clear", 810, 45);
  noFill();
  
  stroke(255, 255, 255);
}

int MouseOnPlanet() {
  int num = -1;
  if (sol.planets != null) {
    for (int i = 0; i < sol.planets.length; i++) {
      Planet p = sol.planets[i];
      XY pos = CalculateNextPosition(p);
      float toSol = sqrt(pow(mouseX, 2) + pow(mouseY, 2));
      if (dist(toSol * cos(p.rot), toSol * sin(p.rot), pos.x, pos.y) <= p.r) {
        num = i;
      }
    }
  }
  return num;
}

void mousePressed() {
  //If the cursor is not over the clear button
  if (mouseX < b1.rectX || mouseX > b1.rectX + b1.rectXSize ||
      mouseY < b1.rectY || mouseY > b1.rectY + b1.rectYSize) {
    if (state == 0 && MouseOnPlanet() != -1) {
      Planet[] temp = sol.planets;
      sol.planets = new Planet[temp.length - 1];
      if (temp.length == 1) {
        sol.planets = null;
      }
      else {
        for (int i = 0; i < temp.length; i++) {
          if (i < MouseOnPlanet()) {
            sol.planets[i] = temp[i];
          }
          else if (i > MouseOnPlanet()) {
            sol.planets[i - 1] = temp[i];
          }
        }
      }
    }
    else if (state == 0) {
      state++;    
    }
    else if (state == 1) {
      state++;
      state1 = new XY(mouseX, mouseY);
    }
    else if (state == 2) {
      state++;
      radius = 2 * sqrt(pow((state1.x - mouseX), 2) + pow((state1.y - mouseY), 2));
    }
    else if (state == 3) {
      state = 0;
      if (newX * 2 + radius <= radius) {
        newRot += pi;
      }
      if (sol.planets != null) {
        Planet[] temp = sol.planets;
        sol.planets = new Planet[temp.length + 1];
        for (int i = 0; i < temp.length; i++) {
          sol.planets[i] = temp[i];
        }
        Planet p = new Planet(newX, 0, newR, newRot, newA, newF);
        sol.planets[temp.length] = p;
        if (newX * 2 + radius > radius) {
          p.t = p.T/2;
        }
      }
      else {
        sol.planets = new Planet[1];
        Planet p = new Planet(newX, 0, newR, newRot, newA, newF);
        sol.planets[0] = p;
        if (newX * 2 + radius > radius) {
          p.t = p.T/2;
        }
      }
    }
  }
}

void mouseReleased() {
  b1.tryClick();
  if (b1.pressed) {
    sol.planets = p;
  }
}
