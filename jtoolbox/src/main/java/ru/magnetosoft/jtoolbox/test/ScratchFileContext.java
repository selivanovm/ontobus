package ru.magnetosoft.jtoolbox.test;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;

import ru.magnetosoft.jtoolbox.common.FileUtils;
import ru.magnetosoft.jtoolbox.resources.ClassPathResource;

public abstract class ScratchFileContext
{
	public class ScratchDir
	{
		private String dir;
		
		protected ScratchDir(String path){
			this.dir = path;
			if(! new File(path).exists() )
				FileUtils.mkdirs(this.dir);
		}
		
		public ScratchDir dir(String name){
			return new ScratchDir( this.dir + FileUtils.f_sep + name );
		}
		
		public ScratchDir back(){
			return new ScratchDir( new File(dir).getParent() );
		}

		
		public ScratchDir copy_from_classpath(String file){
			InputStream is = null;
			OutputStream os = null;
			try{
				int i = file.lastIndexOf("/");
				String fileName = file.substring(i + 1);
				
				is = new ClassPathResource(file).openStream();
				os = new FileOutputStream(this.dir + FileUtils.f_sep + fileName);
				
				byte[] buf = new byte[5000];
				int n = 0;
				while((n = is.read(buf)) != -1)
					os.write(buf, 0, n);
				
				os.close();
				is.close();
			}
			catch(IOException e){
				e.printStackTrace();
//				return false;
			}
			finally{
				try{
					if(os != null) os.close();
				}
				catch(IOException e){
					e.printStackTrace();
				}
				try{
					if(is != null) is.close();
				}
				catch(IOException e){
					e.printStackTrace();
				}
			}
			return this;
		}
		
	}
	
	
	protected ScratchDir rootDir;
	
	
	public String getRootDir(){
		return this.rootDir.dir;
	}
	
	
	protected ScratchDir create_root_dir(String dir){
		FileUtils.rmdir(dir);
		return rootDir = new ScratchDir(dir);
//		FileUtils.mkdirs(dir);
	}
	
	
}
