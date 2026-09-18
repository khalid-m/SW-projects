/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package imgproc;

import java.awt.*;
import javax.swing.*;

public class PhotoAlbum extends JFrame {

    private JScrollPane scrollPane;

    public PhotoAlbum() {
    }

    public Object display(Object args) throws Exception {	

        this.setTitle("Photo Album");
        this.setSize(300, 200);
        this.setBackground(Color.LIGHT_GRAY);

        JPanel topPanel = new JPanel();
        topPanel.setLayout(new FlowLayout());

        //Photo sample = new Photo(null, null);
        //topPanel.add(sample.getDisplayControl());

        if (args == null || !(args instanceof String)) {
            throw new RuntimeException("Invalid type for execute");
        }
        
        // Loops through the list of pictures and displays them
        StringBuffer argsbuf = new StringBuffer((String) args);      
        Photo tmp = null;
        String [] result = parseString(argsbuf);
        int num = 0;

        while (result != null && result[0] != null && result [1] != null) {
            tmp = new Photo(result[0], result[1]);
            topPanel.add(tmp.getDisplayControl());
            result = parseString(argsbuf);
			num ++;
        }

        // Create a tabbed pane
        scrollPane = new JScrollPane();
        scrollPane.setPreferredSize(new Dimension(800, 600));
        scrollPane.getViewport().add(topPanel);

        this.getContentPane().add(scrollPane);
		if (num == 1) {
			this.setTitle("Photo");
		}
        this.pack();

        setVisible(true);
        return null;
    }

     /**
     * Gets next string from pipe-delimited list, or null if end of list..
     */
    private String[] parseString(StringBuffer sb) throws Exception {
        int idx = sb.indexOf("|");
        String [] result = new String [] { null, null};
        if (idx > 0) {
           result[0] = (sb.substring(0, idx));
            sb.delete(0, idx + 1);

            // description
            idx = sb.indexOf("|");
            if (idx > 0) {
                result[1] = (sb.substring(0, idx));
                sb.delete(0, idx + 1);                
            }
        }
        return result;
    }
    
}
