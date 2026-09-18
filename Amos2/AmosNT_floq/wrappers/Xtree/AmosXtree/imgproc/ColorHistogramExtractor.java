package imgproc;

import java.awt.Color;
import java.awt.image.BufferedImage;
import java.awt.image.PixelGrabber;
import java.io.File;

import javax.imageio.ImageIO;

public class ColorHistogramExtractor {

	// histogram of an image
	private int[] m_histogram;

	// number of bins
	private int m_bins = 20;
	
	// String filename
	private String m_filename;

	// Constructor
	public ColorHistogramExtractor() {

		// This program calculate the histogram of 4 regions of an image.
		// The HUE color (0-360) is divided into 20 bins
		m_bins = 20;
		// erase the histogram
		m_histogram = new int[m_bins];
	}

	// Extract color histogram from the given image
	public Object extract(Object args) throws Exception {
		if (!(args instanceof String)) {
			throw new RuntimeException("Invalid type for extract");
		}

	    m_filename = (String) args;
		m_histogram = new int[m_bins];

	    System.out.printf(m_filename + "\n");  
		// --------------------------------------------------
		// Read image file into the BufferedImage
		// --------------------------------------------------
		BufferedImage image = ImageIO.read(new File(m_filename));

		// --------------------------------------------------
		// Grab pixels from the image
		// --------------------------------------------------
		int height = image.getHeight();
		int width = image.getWidth();

		PixelGrabber pGrab = new PixelGrabber(image, 0, 0, width, height, true);
		pGrab.startGrabbing();
		
		int [] pixels = new int [height* width];
		pixels = (int[]) pGrab.getPixels();
		
		// --------------------------------------------------
		// Grab pixels from the image
		// --------------------------------------------------
		Color col = null;
		int   hue = 0;
		for (int i = 0; i < (height * width); i++) {

			col = new Color(pixels[i]);
			hue = rgb_to_hsv(col.getRed(), col.getGreen(), col.getBlue());
			m_histogram[hue / 20] ++;			
		}
		StringBuffer result = new StringBuffer();
		for(int i = 0; i < m_bins - 1; i++) {
			result.append(m_histogram[i]).append(",");
		}
		result.append(m_histogram[m_bins - 1]);
		return result.toString();
	}
	
	// Calculate HUE value (0-360) from RGB
	private int rgb_to_hsv(int red, int green, int blue) {

		double r = red / 255.0;
		double g = green / 255.0;
		double b = blue / 255.0;
		double h = 0.0;
		int hue = 0;

		double max = Math.max(Math.max(r, g), b);
		double min = Math.min(Math.min(r, g), b);
		double s = 0.0;
		double delta = 0.0;

		if (max != 0.0) {
			s = (max - min) / max;
		} else {
			s = 0.0;
		}

		if (s == 0.0) {

		} else {
			delta = (max - min);

			if (r == max) {
				h = (g - b) / delta;
			} else if (g == max) {
				h = 2.0 + (b - r) / delta;
			} else if (b == max) {
				h = 4.0 + (r - g) / delta;
			}

			h *= 60.0;

			while (h < 0.0) {
				h += 360.0;
			}
		}

		hue = (int) (h);
		int sat = (int) (s * 255.0);

		if (sat < 18) {
			hue = 360;
		}

		return hue;
	}
 
}
