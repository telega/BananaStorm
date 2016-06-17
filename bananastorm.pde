/////////////////
// BananaStorm //
/////////////////

PImage banana,bunch,umb; 
PVector gravity, wind;
int nextGust, numBananas;

Banana[] bananas; 
Umbrella umbrella;

void setup(){
  fullScreen(P2D);
  pixelDensity(2); // disble for regular def display
  frameRate(60);
  background(255);
  gravity = new PVector(0,10);
  wind = new PVector(0,0);
  nextGust = 1;
  numBananas = 120;

  //load images
  banana = loadImage(sketchPath() + "/assets/banana_sm.png");
  bunch = loadImage(sketchPath() + "/assets/bunch_sm.png");
  umb = loadImage(sketchPath() + "/assets/umb.png");

  umbrella = new Umbrella();
  bananas = new Banana[numBananas];

  //setup array of bananas
  for (int i = 0; i < bananas.length; i++){
    bananas[i] = new Banana();
  }
}

void draw(){
  background(255);
  
  umbrella.display();

  for(int i = 0; i < bananas.length; i ++){
    bananas[i].update();
    if(bananas[i].checkDisplay()){
      //proximity check handled by banana
      if(bananas[i].checkCollisions()){
        //collision check handled by umbrella.
        umbrella.checkCollisions(bananas[i]);
      }
      bananas[i].display();
    }
    bananas[i].checkEdges();
  }
  
  // wind gusts
  if(frameCount==nextGust){
    wind.set(random(-5,5),random(-1,1)); 
    nextGust += nextGust + int(random(300,900));
  }
  println(frameRate);
}

///////////////////
// BANANA CLASS  //
///////////////////

class Banana{
 PVector location, velocity, acceleration,center;
 float topSpeed, tint, opacity, angle, aVelocity, radius, mass;
 boolean isBunch;
 
 Banana(){
   location = new PVector(random(-.5*width,1.5*width), random(-1.5*height, -100)); 
   velocity = new PVector(0,0); 
   acceleration = new PVector(0,0);
   topSpeed= 10;
   tint = random(200,255);
   angle = random(0,TWO_PI);
   radius = banana.width/2; // faking banana size
   center = new PVector(location.x+(radius),location.y+(radius));  
   opacity = 0;
   //which type of banana are we going to display
   int r = int(random(0,10)); 
   if(r <= 1 ){
     isBunch = true;
     mass = 30;
   } 
   else { 
     isBunch = false;
     mass = 50;
   }
   
 }
 void resetBanana(){
   location.set(random(-.5*width,1.5*width), -400); 
   velocity.set(0,0); 
   acceleration.set(0,0);
   topSpeed= 10;
   tint = random(200,255);
   angle = random(0,TWO_PI);
   center.set(location.x+radius,location.y+radius);
   opacity = 0;

 }
 
 void update(){
   applyForce(gravity);
   applyForce(wind);
   velocity.add(acceleration);
   velocity.limit(topSpeed);
   location.add(velocity);
   acceleration.mult(0);
   center.set(location.x+radius,location.y+radius);
   //rotation    
   aVelocity = velocity.x/50;
   angle += aVelocity;
   //fade in from top
   if(location.y > 255){
     opacity = 255;
   }
   else {
     opacity = location.y;
   }
 }
 
 void applyForce(PVector force){
   PVector f = PVector.div(force,mass);
   acceleration.add(f);
 }
 
 void display(){
   tint(tint,opacity);
   pushMatrix();      
   translate(location.x+(radius), location.y+(banana.height/2));
   rotate(angle);
   translate((-radius),(-banana.height/2));
   if(isBunch){
     image(bunch,0,0);
   }
   else {
     image(banana,0,0);
   }
   popMatrix(); 
   tint(255,255);
 }

 boolean checkCollisions(){
  //preliminary collision check
  if((center.y > height/2) && (center.x < width/2)){
    return true;
  }
  else {
   return false;
  }
 }

boolean checkDisplay(){
  if((location.y > -radius) && (location.x > -100) && (location.x < width+100)){
    return true;
  }
  else{ 
    return false;
  }
} 

 void checkEdges(){  
  if (location.y > height + 100) {
   resetBanana();
  }       
 }

}

////////////////////
// UMBRELLA CLASS //
////////////////////


class Umbrella{
  PVector location;
  float w;  //fake radius of umbrella ellipse

 Umbrella(){
    location = new PVector(width/3,height - (height/3));
    w = umb.width/2;
 }

 void display(){
    image(umb,location.x-w-10,location.y-w-10);
 }

 void checkCollisions(Banana banana){
       //more complex collision check for near objects
       PVector norm = PVector.sub(banana.center, location);
       if(norm.mag()  < w +(banana.radius)){
          //calculate reflection
          float speed = banana.velocity.mag();
          norm.normalize();
          PVector incidence  = PVector.mult(banana.velocity,-1);
          incidence.normalize();
          float dot = incidence.dot(norm);
          //bounce the banana
          banana.velocity.set(2 * norm.x * dot - incidence.x, 2 * norm.y * dot - incidence.y);     
          banana.velocity.mult(speed);
          banana.location.add(banana.velocity); 
        }
      }
}