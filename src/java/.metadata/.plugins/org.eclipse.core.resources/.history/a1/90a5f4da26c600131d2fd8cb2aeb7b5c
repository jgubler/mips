package main;

public class Main {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		System.out.println("sin(pi) = "+sinus((float) Math.PI, 14)
				+ "\nJava-Lib result: "+(float) Math.sin((float) Math.PI));
		
	}

	
	private static float sinus(float x, int steps) {
		float sum = x;
		float pot = x; 
		int fact = 1;
		
		for(int i=3; i<=(3+steps*2); i+=2) {
			pot = pot * x * x;
			fact = fact * (i-1) * i;
			if((i-1)%4==0)
				sum += pot/fact;
			else
				sum -= pot/fact;
		}
		return sum;
	}
}
