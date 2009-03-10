package ru.magnetosoft.esb.mq.statistic;

public class AvgParam implements StatisticParam
{
	protected String name;
	
	protected double max;
	protected double min;
	protected double total;
	protected int n;

	public String name() {
		return this.name;
	}

	public void reset() {
		min = max = total = 0.0;
		n = 0;
	}
	
	public void add(double value){
		if(n == 0){
			min = max = total = value;
		}
		else{
			min = Math.min(min, value);
			max = Math.max(max, value);
			total += value;
		}
		n++;
	}
	
	
	public double avg(){
		return (n == 0) ? 0 : total / (double)n;
	}
	
	public double min(){
		return min;
	}

	public double max(){
		return max;
	}
	
	@Override
	public String toString() {
		return String.format("%f ( %f - %f )", avg(), min(), max());
	}
}
