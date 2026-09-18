package org.jSoapServer.utils;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class FileUtils {

    /**
     * @since 0.2.8
     */
    public static byte[] read(InputStream source) throws IOException {
        ByteArrayOutputStream byteOut = new ByteArrayOutputStream();
        copy(source,byteOut);
        return byteOut.toByteArray();
    }
    
    /**
     * Copy data from the source stream to the destination stream
     * @param source
     * @param dest
     * @return the amount of copied bytes
     * @throws IOException
     */
    public static int copy(InputStream source, OutputStream dest) throws IOException {
        byte[] buffer = new byte[4096];
        
        int c, total = 0;
        while ((c = source.read(buffer)) > 0) {
            dest.write(buffer, 0, c);
            dest.flush();
            total += c;
        }
        dest.flush();
        
        return total;
    }

    /**
     * 
     * @param in
     * @return
     * @throws IOException
     * @since 0.2.6
     */
    public static String readLine(InputStream in) throws IOException {
        
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        
        int len = 0, b = 0;      
        while ((b = in.read()) != -1) {
            if (b != '\n' && b != '\r') {
                out.write(b);
                len++;
            } else if (b == '\n') break;
        }
        
        return out.toString();
    }

    public static String loadStringFromFile(File deploymentFile) throws IOException {
        InputStream in = null;
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream((int)deploymentFile.length());
            in = new FileInputStream(deploymentFile);
            copy(in, out);
            return out.toString();
        } finally {
            if (in != null) try { in.close(); } catch (Exception e) {/* */}
        }
    }
}
