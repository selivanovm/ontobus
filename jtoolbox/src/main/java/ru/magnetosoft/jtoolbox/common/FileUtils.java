package ru.magnetosoft.jtoolbox.common;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;

public class FileUtils
{
	public static String f_sep = System.getProperty("file.separator");
	
	
	private FileUtils(){}
	
	
	
	
	public static boolean mkdirs(String dir){
		return new File(dir).mkdirs();
	}
	
	
	/**
	 * Рекурсивное удаление каталога со всем содержимым
	 * @param dir каталог
	 * @return true при успешном удалении каталога
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
   * Копирование файла.
   * Данная реализация использует файловые каналы 
   * @param src файл-источник данных
   * @param dst файл-цель копирования (при отсутствии файла, он будет создан)
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
	
	public static File curdir(){
		return new File(System.getProperty("user.dir"));
	}
	
	public static File tempdir(){
		return new File(System.getProperty("java.io.tmpdir"));
	}
}
