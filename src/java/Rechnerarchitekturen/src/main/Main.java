package main;

public class Main {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		System.out.println("sin(pi) = "+sinus((float) Math.PI)
				+ "\nJava-Lib result: "+(float) Math.sin((float) Math.PI));
		
	}

	
	private static float sinus(float x) {
		float sum = x;
		float pot = x; 
		int fact = 1;
		
		for(int i=1; i<20; i+=2) {
			pot = pot * x * x;
			fact = fact * (i+1) * (i+2);
			if((i-1)%4==0)
				sum += pot/fact;
			else
				sum -= pot/fact;
		}
		return sum;
	}
}
