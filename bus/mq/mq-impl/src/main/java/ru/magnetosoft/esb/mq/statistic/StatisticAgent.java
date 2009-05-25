package ru.magnetosoft.esb.mq.statistic;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.magnetosoft.jtoolbox.common.ArrayUtils;


public abstract class StatisticAgent
{
	private List<Field> paramFields = new ArrayList<Field>();
	
	public StatisticAgent() {
		Class<?> clazz = this.getClass();
		Field[] fields = clazz.getDeclaredFields();
		for(int i = 0; i < fields.length; i++){
			Field fld = fields[i];
			fld.setAccessible(true);
			Class<?> type = fld.getType();
			if(ArrayUtils.contains(type.getInterfaces(), StatisticParam.class))
				paramFields.add(fld);
		}
	}
	
	public Map<String, StatisticParam> parameters(){
		Map<String, StatisticParam> result = new HashMap<String, StatisticParam>();
		for(Field fld : paramFields){
			try{
				result.put(fld.getName(), (StatisticParam)fld.get(this));
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}		
		return result;
	}
	
	public void reset(){
		Map<String, StatisticParam> params = parameters();
		for(StatisticParam param : params.values())
			param.reset();
	}
}
