class Planet {
  constructor(x1, y1, r1, rot1, a1, f1) {
    this.xy = createVector(x1, y1);
    this.r = r1;
    this.rot = rot1;
    this.a = a1;
    this.f = f1;
    this.T = sqrt(k * pow(a1, 3));
    this.t = 0;
  }
}

class SolarSystem {
  constructor(x, y, d, p) {
    this.sunX = x;
    this.sunY = y;
    this.sunDiam = d;
    this.planets = p;
  }
}


function CalculateNextPosition(planet) {
  let E = CalculateE(planet);
  let x = -planet.a * (cos(E) - planet.f);
  let y = -planet.a * sqrt(1 - pow(planet.f, 2)) * sin(E);
  return createVector(x, y);
}

function CalculateE(planet) {
  if (planet.t > planet.T) {
    planet.t = 0;
  }
  let M = (2 * pi * planet.t)/planet.T;
  let E = pi;
  for (let i = 0; i < 5; i++) {
    E = E - (E - planet.f * sin(E) - M)/(1 - planet.f * cos(E));
  }
  return E;
}

var state1;
var state2;
var radius = 0;
var state = 0;
var newX = 0;
var newB = 0;
var newR = 0;
var newRot = 0;
var newA = 0;
var newF = 0;

var pi = 3.1415;
var t = 0;
var k = 4.2;
var p = null;
var sol = new SolarSystem(225, 225, 25, p);

var b1;

function setup() {
  createCanvas(450, 450);
  stroke(255, 255, 255);
  strokeWeight(2);
	
  state1 = createVector(0, 0);
  state2 = createVector(0, 0);
	
  b1 = new Button(400, 5, 40, 25);
  
  sol.planets = [ new Planet(100, 0, 10, 0, 34, 0.1), new Planet(200, 0, 20, 2, 120, 0.2), new Planet(10, 0, 5, 1, 100, 0.8) ];
}

function draw() {
  background(0, 0, 0);
  fill(0, 0, 0, 0);

  //Draw sun
  ellipse(sol.sunX, sol.sunY, sol.sunDiam, sol.sunDiam);
  
  //Draw planet paths
  if (sol.planets != null) {
    for (let i = 0; i < sol.planets.length; i++) {
      let p = sol.planets[i];
      let b = p.a * sqrt(1 - pow(p.f, 2));
      let c = sqrt(pow(p.a, 2) - pow(b, 2));
      push();    
      translate(sol.sunX, sol.sunY);
      //float rotate = sol.planets[i].rot;
      rotate(sol.planets[i].rot);
      ellipse(c, 0, 2 * p.a, 2 * b);
      pop();
      
      //Increment time
      p.t += 3;
    }
  }
  
  //Draw planets
  fill(0, 0, 0);
  if (sol.planets != null) {
    for (let i = 0; i < sol.planets.length; i++) {
      let newPos = CalculateNextPosition(sol.planets[i]);
      sol.planets[i].xy = newPos;
      
      push();    
      translate(sol.sunX, sol.sunY);
      rotate(sol.planets[i].rot);
      ellipse(newPos.x, newPos.y, sol.planets[i].r, sol.planets[i].r);
      pop();
    }
  }
  
  //Draw inital circle
  if (state == 1) {
    let diam = 2 * sqrt(pow((sol.sunX - mouseX), 2) + pow((sol.sunY - mouseY), 2));
    if (diam < sol.sunDiam) {
      diam = sol.sunDiam;
    }
    fill(0, 0, 0, 0);
    ellipse(sol.sunX, sol.sunY, diam, diam);
    radius = diam / 2;
  }
  //Turn orbit into ellipse
  else if (state == 2) {
    let theta = atan((mouseY - sol.sunY)/(mouseX - sol.sunX));
    if (mouseX < sol.sunX) {
      theta = theta + pi;
    }
    let dist = sqrt(pow((mouseX - sol.sunX), 2) + pow((mouseY - sol.sunY), 2));
    if (dist < sol.sunDiam / 2.0) {
      dist = sol.sunDiam / 2.0;
    }
    let b = sqrt(pow((radius + dist)/2, 2) - pow((dist + radius)/2 - radius, 2));
    
    fill(0, 0, 0, 0);
    push();    
    translate(sol.sunX, sol.sunY);
    rotate(theta);
    ellipse((dist - radius)/2, 0, radius + dist, 2 * b);
    pop();
    newX = (dist - radius)/2;
    newB = b;
    newRot = theta;
    newA = (radius + dist)/2;
    newF = sqrt(1 - (pow(b, 2)/pow(newA, 2)));
    //state2 = new XY(mouseX, mouseY);
    state2 = createVector(sol.sunX + ((dist - radius)/2 + (radius + dist)/2) * cos(theta), 
    sol.sunY + ((dist - radius)/2 + (radius + dist)/2) * sin(theta));
  }
  //Create the planet
  else if (state == 3) {
    fill(0, 0, 0, 0);
    push();    
    translate(sol.sunX, sol.sunY);
    rotate(newRot);
    ellipse(newX, 0, 2 * newA, 2 * newB);
    pop();
    
    fill(0, 0, 0);
    let r = 2 * sqrt(pow((state2.x - mouseX), 2) + pow((state2.y - mouseY), 2));
    ellipse(state2.x, state2.y, r, r);
    newR = r;
  }
  
  b1.update();
  b1.display();
  
  fill(0, 0, 0);
  textSize(15);
  text("Clear", 402, 22.5);
  noFill();
  
  stroke(255, 255, 255);
}

function MouseOnPlanet() {
  let num = -1;
  if (sol.planets != null) {
    for (let i = 0; i < sol.planets.length; i++) {
      let p = sol.planets[i];
      let pos = CalculateNextPosition(p);
      let toSol = sqrt(pow(mouseX, 2) + pow(mouseY, 2));
      if (dist(toSol * cos(p.rot), toSol * sin(p.rot), pos.x, pos.y) <= p.r) {
        num = i;
      }
    }
  }
  return num;
}

function mousePressed() {
  //If the cursor is not over the clear button
  if (mouseX < b1.rectX || mouseX > b1.rectX + b1.rectXSize ||
      mouseY < b1.rectY || mouseY > b1.rectY + b1.rectYSize) {
    if (state == 0 && MouseOnPlanet() != -1) {
      let temp = sol.planets;
      sol.planets = new Array(temp.length - 1);
      if (temp.length == 1) {
        sol.planets = null;
      }
      else {
        for (let i = 0; i < temp.length; i++) {
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
      state1 = createVector(mouseX, mouseY);
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
        let p = new Planet(newX, 0, newR, newRot, newA, newF);
        sol.planets.push(p);
        if (newX * 2 + radius > radius) {
          p.t = p.T/2;
        }
      }
      else {
        let p = new Planet(newX, 0, newR, newRot, newA, newF);
        sol.planets = [p];
        if (newX * 2 + radius > radius) {
          p.t = p.T/2;
        }
      }
    }
  }
}

function mouseReleased() {
  b1.tryClick();
  if (b1.pressed) {
    sol.planets = p;
  }
}
