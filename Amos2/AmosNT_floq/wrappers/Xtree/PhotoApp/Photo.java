/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

import java.awt.Color;
import java.awt.LayoutManager;
import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JLabel;
import javax.swing.SpringLayout;
import javax.swing.border.Border;

/**
 *
 * @author thanh
 */
public class Photo {
    private String m_description;
    private ImageIcon   m_icon;
    private JLabel m_displayControl;

    /*Constructor
     If parameters are NULLs, they get the default values*/
    public Photo(String imagefile, String description) {
        // Gets the description
        m_description = description == null ? "Sample" : description;

        // Loads the iamge
        m_icon = imagefile == null ?
                  (new ImageIcon(getClass().getResource("/resource/sample.jpg")))
                 : (new ImageIcon(imagefile));
    }
    // Gets the image
    public Icon getPhoto() {
        return m_icon;
    }
    // Gets the description
    public String getDescription() {
        return m_description;
    }
    
    // Gets the display control
    public JLabel getDisplayControl() {
        if (m_displayControl == null) {
            m_displayControl = new JLabel(m_icon);
            m_displayControl.setBorder(
                    BorderFactory.createLineBorder(Color.BLACK));

            //Set the position of the text, relative to the icon:
            m_displayControl.setVerticalTextPosition(JLabel.BOTTOM);
            m_displayControl.setHorizontalTextPosition(JLabel.CENTER);
            m_displayControl.setText(m_description);

        }
        return m_displayControl;
    }
}
