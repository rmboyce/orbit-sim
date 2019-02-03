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
  /*
  XY toXY() {
    return new XY(w, h);
  }*/

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
  
  void rotate(float degrees, SolarSystem s) {
    /*
    float r = sqrt(pow(x, 2) + pow(y, 2));
    float angle = atan(y/x);
    if (x <= 0) {
      angle = pi - angle;
    }
    angle += degrees;
    x = r * cos(angle);
    y = r * sin(angle);
    */
  }
}

class SolarSystem {
  float sunX;
  float sunY;
  float sunWidth;
  float sunHeight;
  Planet[] planets;
  
  SolarSystem(float x, float y, float w, float h, Planet[] p) {
    sunX = x;
    sunY = y;
    sunWidth = w;
    sunHeight = h;
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
/*
float getC(Planet planet) {
  float b = planet.a * sqrt(1 - pow(planet.f, 2));
  float c = sqrt(pow(planet.a, 2) + pow(b, 2));
  return c;
}*/
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
Planet[] p = null;//{ new Planet(0, 0, 20, 20, pi/2, 50, 0.5) };
SolarSystem sol = new SolarSystem(500, 400, 50, 50, p);

void setup() {
  size(1000, 800);
  stroke(255, 255, 255);
  strokeWeight(3);
}

void draw() {
  background(0, 0, 0);
  fill(0, 0, 0, 0);
  //fill(255, 255, 255);
  //Draw sun
  ellipse(sol.sunX, sol.sunY, sol.sunWidth, sol.sunHeight);
  
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
      p.t++;
    }
  }
  
  //Draw planets
  fill(0, 0, 0);
  if (sol.planets != null) {
    for (int i = 0; i < sol.planets.length; i++) {
      XY newPos = CalculateNextPosition(sol.planets[i]);
      sol.planets[i].xy = newPos;
      newPos.rotate(sol.planets[i].rot, sol);
      pushMatrix();    
      translate(sol.sunX, sol.sunY);
      rotate(sol.planets[i].rot);
      //newPos.x + sol.sunX, newPos.y + sol.sunY
      ellipse(newPos.x, newPos.y, sol.planets[i].r, sol.planets[i].r);
      popMatrix();
    }
  }
  
  if (state == 1) {
    float rad = 2 * sqrt(pow((sol.sunX - mouseX), 2) + pow((sol.sunY - mouseY), 2));
    fill(0, 0, 0, 0);
    ellipse(sol.sunX, sol.sunY, rad, rad);
    radius = rad / 2;
  }
  else if (state == 2) {
    //ellipse(state1.x, state1.y, radius, radius);
    float theta = atan((mouseY - sol.sunY)/(mouseX - sol.sunX));
    //if (mouseX <= sol.sunX && mouseY < sol.sunY) {
    //  theta = theta + pi;
    //}
    if (mouseX < sol.sunX) {
      theta = theta + pi;
    }
    float dist = sqrt(pow((mouseX - sol.sunX), 2) + pow((mouseY - sol.sunY), 2));
    float b = sqrt(pow((radius + dist)/2, 2) - pow((dist + radius)/2 - radius, 2));
    fill(0, 0, 0, 0);
    //ellipse(sol.sunX, sol.sunY, radius, radius);
    pushMatrix();    
    translate(sol.sunX, sol.sunY);
    rotate(theta);
    ellipse((dist - radius)/2, 0, radius + dist, 2 * b);
    popMatrix();
    newX = (dist - radius)/2;
    //print(newX);
    //newY = 0;
    //newW = radius + dist;
    newB = b;
    newRot = theta;
    newA = (radius + dist)/2;
    //print(newA + ", " + newB);
    newF = sqrt(1 - (pow(b, 2)/pow(newA, 2)));
    state2 = new XY(mouseX, mouseY);
  }
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
      print((toSol * cos(p.rot)) + ", " + (toSol * sin(p.rot)) + " ---- " +pos.x + ", " + pos.y + "|");
    }
  }
  return num;
}

void mouseClicked() {
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
