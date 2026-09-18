package logdir;

import java.nio.file.*;
import java.io.File;
import java.io.IOException;
import java.util.concurrent.TimeUnit;
import static java.nio.file.StandardWatchEventKinds.*;

import callin.*;
import callout.*;

public class LogDir {
    
    public void logDirectory(CallContext ctx, Tuple tpl) throws AmosException, IOException {
	FileSystem defaultFS = FileSystems.getDefault();
	WatchService watcher = defaultFS.newWatchService();
	String dir = tpl.getStringElem(0);
	Path watchedPath = defaultFS.getPath(dir);
	watchedPath.register(watcher,ENTRY_CREATE,ENTRY_DELETE);
	//System.out.println("listen on " + dir);
    	for(;;) {
    	    WatchKey key;
    	    try {
		for(;;) {
		    Oid bg = ctx.getBG();
		    ctx.enterBG(bg);
		    key = watcher.poll(250,TimeUnit.MILLISECONDS);
		    ctx.leaveBG(bg);
		    if(key == null) {
			tpl.setElem(1,(Oid)null);
			ctx.emit(tpl);
		    }
		    else break;
		}
    	    }
    	    catch(InterruptedException e) {
    		System.out.println("Interrupted.");
    		return;
	    }
    	    for(WatchEvent<?> event: key.pollEvents()) {
    		WatchEvent.Kind<?> kind = event.kind();
    		if(kind == OVERFLOW) {
    		    System.out.println("Overflow!");
    		    continue;
    		}
    		else if(kind == ENTRY_CREATE) {
		    int access = 0;
		    int attempts = 0;
		    Oid bg = ctx.getBG();
		    ctx.enterBG(bg);
    		    Path newFile = watchedPath.resolve((Path)event.context());
		   
		    long size = 0;
		    // at most, it tries in 10 attempts ( 9 seconds in total)
		    while((access == 0 && attempts < 10)){
			try {
			    attempts = attempts + 1;
			    size = Files.size(newFile);
			    Thread.sleep(200 * attempts); 
			    if (size == Files.size(newFile)) { // Copying is completely done
				access = 1;
			    }

			} catch (SecurityException e) {
			    try { 
				Thread.sleep(200 * attempts); 
			    } catch (InterruptedException ie) {
				
			    }	 

			} catch (InterruptedException iee) {
			    
			} catch (IOException io){
			    
			}			   
		    }					    
		    ctx.leaveBG(bg);
		    // Emit only if file's accessibility is fine.
		    if (access == 1) {
			tpl.setElem(1,newFile.toString().replace("\\","/"));
		    } else {
			System.out.println("Cannot wait more! Skip ");
		    }
		    ctx.emit(tpl);
    		}
    		else if(kind == ENTRY_DELETE) {
    		    Path deletedFile = watchedPath.resolve((Path)event.context());
		    // now what?
    		}
    	    }
    	    if(!key.reset()) {
		System.out.println("Key is no longer valid.");
    		break;
	    }
    	}
	System.out.println("I'm out!");
    }
}
