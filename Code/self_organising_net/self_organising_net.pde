// Carla de Beer
// January 2014
// Self-organising net structure
// Steer, seek arrive alogorithms based on those by Daniel Shiffman (Nature of Code)

Particle [][] particles;
PVector [][] finalPos;

PVector loc;
PVector eye;
PVector centre;
PVector up;
int u_row = 26;
int v_row = 25;
float maxspeed = 1.5;
float maxforce = 0.008;
boolean showParticles;
boolean reverse = false;
float mult = 22;

void setup()
{
  size(750, 750);
  smooth();
  showParticles = false;
  particles = new Particle [u_row][v_row];
  finalPos = new PVector [u_row][v_row];

  for (int i = 0; i < u_row; i++) 
  {
    for (int j = 0; j < v_row; j++) 
    {
      PVector loc = new PVector (random(width-(width - (u_row-1)*mult)), random(height-(height - (u_row-1)*mult)));
      if (!reverse)
      {
        particles[i][j] = new Particle(loc);
        finalPos[i][j] = new PVector(i*mult, j*mult);
      }
      else
      {
        PVector loc1 = new PVector(i*mult, j*mult);
        particles[i][j] = new Particle(loc1);
        finalPos[i][j] = new PVector(random(width-(width - (u_row-1)*mult)), random(height-(height - (u_row-1)*mult)));
      }
      //println("finalPos = " + finalPos[i][j]);
    }
  }
}

void draw()
{
  background(100);//#71CB29);
  pushMatrix();
  translate((width - (u_row-1)*mult)/2, (height - (v_row-1)*mult)/2);

  for (int i = 0; i < u_row; i++)
  {
    for (int j = 0; j < v_row; j++) 
    { 
      particles[i][j].arrive(finalPos[i][j]);
      particles[i][j].run();
    }
  }

  stroke(255);
  strokeWeight(1);

  for (int j = 0; j < v_row-2; j++)
  {
    for (int i=(j%2)*2; i < u_row-3;  i+=4) 
    {               
      if (showParticles)
      {
        particles[i][j].drawParticle(particles, i, j);
      }
      particles[i][j].drawLines(particles, i, j);
    }
  }

  for (int j = 2; j < v_row-2; j+=2) 
  {   
    line(particles[0][j+1].pos.x, particles[0][j+1].pos.y, particles[1][j].pos.x, particles[1][j].pos.y);
  } 

  for (int j = 2; j < v_row; j+=2) 
  {   
    line(particles[24][(j-1)].pos.x, particles[24][(j-1)].pos.y, particles[25][j].pos.x, particles[25][j].pos.y);
  } 

  for (int i = 0; i < u_row; i+=4) 
  {   
    line(particles[i][1].pos.x, particles[i][1].pos.y, particles[i+1][0].pos.x, particles[i+1][0].pos.y);
  } 

  for (int i = 2; i < u_row; i+=4) 
  {   
    line(particles[i][0].pos.x, particles[(i)][0].pos.y, particles[(i+1)][1].pos.x, particles[i+1][1].pos.y);
  } 

  for (int i = 1; i < u_row-1; i+=4) 
  {   
    line(particles[i][24].pos.x, particles[i][24].pos.y, particles[i+1][24].pos.x, particles[i+1][24].pos.y);
  } 

  for (int i = 3; i < u_row-1; i+=4) 
  {   
    line(particles[i][23].pos.x, particles[i][23].pos.y, particles[i+1][23].pos.x, particles[i+1][23].pos.y);
  } 

  popMatrix();
}

void mouseReleased()
{
  showParticles = !showParticles;
}

void keyReleased()
{
  if (key == 'R' || key =='r') // show particles
  {
    setup();
    draw();
  }
  if (key == 'U' || key =='u') // start in reverse
  {
    reverse = true;
    setup();
    draw();
    reverse = false;
  }
  if (key == 'S' || key =='s') saveFrame("image-###.tiff");
}
