package main;

import java.util.Scanner;

public class Main {

	public static final float PI = (float) Math.PI;
	public static final int steps = 6;
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		StringBuilder sb = new StringBuilder();
		Scanner s = new Scanner(System.in);
		System.out.println("Trigonomie-Rechnung in einem Zahlenbereich\nUntere Grenze eingeben: ");
		final float u = s.nextFloat();
		System.out.println("Obere Grenze eingeben: ");
		final float o = s.nextFloat();
		s.close();
		for(float i=u;i<o;i+=0.1){
			sb.append("\nsin(").append(i).append(") = ").append(sinus(i));
			sb.append("\n  Java-Lib result: ").append((float) Math.sin(i));
			sb.append("\ncos(").append(i).append(") = ").append(cosinus(i));
			sb.append("\ntan(").append(i).append(") = ").append(tangent(i));
			sb.append("\n--");
		}
		sb.append("\nsin(").append(o).append(") = ").append(sinus(o));
		sb.append("\n  Java-Lib result: ").append((float) Math.sin(o));
		sb.append("\ncos(").append(o).append(") = ").append(cosinus(o));
		sb.append("\ntan(").append(o).append(") = ").append(tangent(o));
		
		System.out.println(sb.toString());
	}

	
	private static float sinus(float x) {
		x = modulo(x, 2*PI);
		if(x<-PI/2)
			x += 2*PI;
		if (-PI/2 <= x && x <= PI/2)
			return sin0(x);
		else if(x >= 1.5*PI)
			return sin0(x-2*PI);
		else {
			// PI/2 < x < 1.5*PI, spiegeln!
			return sin0(PI/2 - x);
		}
	}
	
	private static float sin0(float x) {
		float sum = x;
		float pot = x; 
		float fact = 1;
		for(int i=3; i<=3+(steps-1)*2; i+=2) {
			pot = pot * x * x;
			fact = fact * (i-1) * i;
			if((i-1)%4==0)
				sum += pot/fact;
			else
				sum -= pot/fact;
		}
		return sum;	
	}
	
	private static float cosinus(float x){
		return sinus(x+PI/2);
	}
	private static float tangent(float x){
		if(modulo(x, PI) == PI/2 || modulo(x, PI) == -PI/2){
			System.out.println("ERROR: tan("+x+") not defined!");
			return 0;
		}
		x = modulo(x, PI);
		if(x>PI/2)
			x-=PI;
		else if(x<-PI/2)
			x+=PI;
		// x is now between -PI/2 and PI/2
		return tan0(x);
	}
	
	private static float tan0(float x){
		return sin0(x)/sin0(x+PI/2);
	}
	/**
	 * Implementing a%b for floats
	 * @param a
	 * @param b
	 * @return
	 */
	private static float modulo(float a, float b){
		double x = a/b;
		int y = (int) x;
		return a-y*b;
	}
}
