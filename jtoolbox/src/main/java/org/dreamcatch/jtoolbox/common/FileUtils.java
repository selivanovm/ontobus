package org.dreamcatch.jtoolbox.common;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;

public class FileUtils
{
	
	public static String f_sep = System.getProperty("file.separator");
	public static String path_delim_pattern = "/";
	
	
	private FileUtils(){}
	
	
	
	
	public static boolean mkdirs(String dir){
		return new File(dir).mkdirs();
	}
	
	
	/**
	 * Р РµРєСѓСЂСЃРёРІРЅРѕРµ СѓРґР°Р»РµРЅРёРµ РєР°С‚Р°Р»РѕРіР° СЃРѕ РІСЃРµРј СЃРѕРґРµСЂР¶РёРјС‹Рј
	 * @param dir РєР°С‚Р°Р»РѕРі
	 * @return true РїСЂРё СѓСЃРїРµС€РЅРѕРј СѓРґР°Р»РµРЅРёРё РєР°С‚Р°Р»РѕРіР°
	 */
  public static boolean rmdir(File dir){
    File[] files = dir.listFiles();
    if(files == null) return false;//throw new FileNotFoundException("Directory to delete not found [" + dir + "]"); 
    for(int i = 0; i < files.length; i++){
    	if(files[i].isDirectory()) rmdir(files[i]);
    	else files[i].delete(); 
    }
    return dir.delete();
  } 	
	
  public static boolean rmdir(String path){
  	return rmdir(new File(path));
  }
	
  
  /**
   * РљРѕРїРёСЂРѕРІР°РЅРёРµ С„Р°Р№Р»Р°.
   * Р”Р°РЅРЅР°СЏ СЂРµР°Р»РёР·Р°С†РёСЏ РёСЃРїРѕР»СЊР·СѓРµС‚ С„Р°Р№Р»РѕРІС‹Рµ РєР°РЅР°Р»С‹ 
   * @param src С„Р°Р№Р»-РёСЃС‚РѕС‡РЅРёРє РґР°РЅРЅС‹С…
   * @param dst С„Р°Р№Р»-С†РµР»СЊ РєРѕРїРёСЂРѕРІР°РЅРёСЏ (РїСЂРё РѕС‚СЃСѓС‚СЃС‚РІРёРё С„Р°Р№Р»Р°, РѕРЅ Р±СѓРґРµС‚ СЃРѕР·РґР°РЅ)
   * @throws IOException
   */
  public static void copy(File src, File dst) throws IOException{
  	
  	FileInputStream fis = new FileInputStream(src);
  	FileOutputStream fos = new FileOutputStream(dst);
  	
    FileChannel fcin = fis.getChannel();
    FileChannel fcout = fos.getChannel();

    fcin.transferTo(0, fcin.size(), fcout);
  	
    fcout.close();
    fcin.close();
    fos.close();
    fis.close();
  }
	
	public static String curdir(){
		return System.getProperty("user.dir");
	}
	
	public static String tempdir(){
		return System.getProperty("java.io.tmpdir");
	}
	
	public static String build_path(String... items){
		StringBuffer sb = new StringBuffer();
		for(int i = 0; i < items.length; i++){
			if(sb.length() > 0) sb.append(FileUtils.f_sep);
			sb.append(items[i]);			
		}
		return sb.toString();
	}
	
	public static String naturalize_path(String path){
		return path.replaceAll(path_delim_pattern, f_sep);
	}
}
