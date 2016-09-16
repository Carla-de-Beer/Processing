// Used for testing the code with POJO Java, where the Processing random() method has no meaning.

import java.util.Random;

public class MyRandom {

  public MyRandom() {

  }

  public int randomInt(int min, int max) {
    Random rand = new Random();
    int randomNum = rand.nextInt((max - min)) + min;
    return randomNum;
  }

  public int randomInt(int max) {
    Random rand = new Random();
    int randomNum = rand.nextInt((max));
    return randomNum;
  }

  public double randomDouble() {
    Random rand = new Random();
    double randomNum = 1 * rand.nextDouble();
    return randomNum;
  }

}