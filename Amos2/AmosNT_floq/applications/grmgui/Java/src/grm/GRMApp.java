/*
 * GRMApp.java
 */

package grm;

import org.jdesktop.application.Application;
import org.jdesktop.application.SingleFrameApplication;
import callin.*;
import java.util.Locale;
import javax.swing.JOptionPane;

/**
 * The main class of the application.
 */
public class GRMApp extends SingleFrameApplication {

    /**
     * At startup create and show the main frame of the application.
     */
    @Override protected void startup() {
        show(new GRMView(this));
    }

    /**
     * This method is to initialize the specified window by injecting resources.
     * Windows shown in our application come fully initialized from the GUI
     * builder, so this additional configuration is not needed.
     */
    @Override protected void configureWindow(java.awt.Window root) {
    }

    /**
     * A convenient static getter for the application instance.
     * @return the instance of GRMApp
     */
    public static GRMApp getApplication() {
        return Application.getInstance(GRMApp.class);
    }

    /**
     * Main method launching the application.
     */
    public static void main(String[] args) throws AmosException {
        JOptionPane.setDefaultLocale(Locale.US); //display all buttons with labels in English

        Connection.initializeAmos(args);        

        launch(GRMApp.class, args);
    }
}
