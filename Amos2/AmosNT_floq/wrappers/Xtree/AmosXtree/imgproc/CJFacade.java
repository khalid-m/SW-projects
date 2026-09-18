package imgproc;

public class CJFacade implements CJProxy {

	private ColorHistogramExtractor m_extractor;
	private PhotoAlbum m_photoAlbum;

	// Constructor
	public CJFacade() {	
		m_extractor = new ColorHistogramExtractor();
	}

	// Extract color histogram from the given image
	public Object extract(Object args) throws Exception {
		return m_extractor.extract(args);
	}

	// Display PhotoAlbum
	public Object display(Object args) throws Exception {
		PhotoAlbum mainFrame = new PhotoAlbum();
        mainFrame.display(args);
		return "Ok";

	}
}
