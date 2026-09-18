package udbl.amos.purejavaclient;

import java.awt.*;
import java.applet.*;
import java.io.*;
import java.net.*;
public class LispGui extends Applet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	public CQueue inqueue;
    public void start()
    {
        if(lisp!=null)
        lisp.start();
    }
    public void stop()
    {
        if(lisp!=null) lisp.stop();
    }
    void loadLispProgram(String urlName)
    {
		URL url=null;
		InputStream instream=null;
//		CQueue inqueue;
		int rl=0;
		int x=0;
		try{
    		url=new URL(urlName);
    	}
    	catch(MalformedURLException e){
            printArea.append("URL Format Error\n");
    	}
        try{
            instream=url.openStream();
        }
        catch(IOException e){
            printArea.append("URL Open Error\n");
        }
//        inqueue=new CQueue();
        while(true){
            try{
                rl=instream.available();
            }
            catch(IOException e){}
            if(rl<=0) {
                try{ instream.close(); }
                catch(IOException e){printArea.append("close failed\n");}
                lisp.evals(inqueue);
                return;
            }
            try{
                x=instream.read();
            }
            catch(IOException e)
            { printArea.append("input error.\n");}

            inqueue.put(x);
            printArea.append(""+(char)x);
        }

    }
	void addButton_Clicked(Event event) {

		urlChoice.addItem(sourceURL.getText());
	}

	void loadButton2_Clicked(Event event) {

		loadLispProgram(
                  "http://yama-linux.cc.kagoshima-u.ac.jp/~yamanoue/researches/java/Lisp/"
                  + urlChoice.getSelectedItem());
	}

    public void traceFlag_Action(Event e)
    {
         printArea.append("Trace on/off\n");
    }
    void LoadButton_Clicked(Event event) {

		loadLispProgram(sourceURL.getText());
	}

	void printEnv_Clicked(Event event) {
		lisp.plist("\n.environment=",lisp.environment);
	}

    public ALisp lisp;
	void evalButton_Clicked(Event event) {
		String input=readArea.getText();
		printArea.append("> "+input+"\n");
		inqueue.putString(input);
		//lisp.evals(inqueue);
		readArea.setText("");
		readArea.repaint();
	}
	public void init() {
		super.init();
		setLayout(null);
		addNotify();
		resize(548,504);
		label2 = new java.awt.Label("Input an S expression in the following area and push \"eval\" button.");
		label2.setBounds(24,228,360,24);
		add(label2);
		label1 = new java.awt.Label("Output");
		label1.setBounds(24,48,100,24);
		add(label1);
		printArea = new java.awt.TextArea();
		printArea.setBounds(24,72,480,144);
		add(printArea);
		evalButton = new java.awt.Button("eval");
		evalButton.setBounds(36,372,84,24);
		add(evalButton);
		readArea = new java.awt.TextArea();
		readArea.setBounds(24,252,480,108);
		add(readArea);
		label3 = new java.awt.Label("A Small Lisp Interpreter on the Net.");
		label3.setBounds(24,12,264,40);
		label3.setFont(new Font("Dialog", Font.BOLD, 14));
		add(label3);
		printEnv = new java.awt.Button("print env");
		printEnv.setBounds(144,372,72,24);
		add(printEnv);
		sourceURL = new java.awt.TextField();
		sourceURL.setBounds(72,408,276,24);
		//		add(sourceURL);
		label4 = new java.awt.Label("URL");
		label4.setBounds(24,408,36,24);
		//		add(label4);
		LoadButton = new java.awt.Button("Load");
		LoadButton.setBounds(360,408,60,24);
		//		add(LoadButton);
		addButton = new java.awt.Button("Add to List");
		addButton.setBounds(432,408,72,24);
		//		add(addButton);
		loadButton2 = new java.awt.Button("Load");
		loadButton2.setBounds(444,444,60,24);
		add(loadButton2);
		traceFlag = new java.awt.Checkbox("Trace On");
		traceFlag.setBounds(240,372,100,24);
		add(traceFlag);
		urlChoice = new java.awt.Choice();
		urlChoice.addItem("set.lsp");
		urlChoice.addItem("hanoi.lsp");
		urlChoice.addItem("ttt.lsp");
		add(urlChoice);
		urlChoice.setBounds(72,444,360,20);
		label5 = new java.awt.Label("examples");
		label5.setBounds(12,444,48,16);
		add(label5);
		//}}

        lisp=new ALisp();
        inqueue=new CQueue();
        lisp.init(readArea,printArea,inqueue,this);
        lisp.start();

	}

	@SuppressWarnings("deprecation")
	public boolean handleEvent(Event event) {
		if (event.target == evalButton && event.id == Event.ACTION_EVENT) {
			evalButton_Clicked(event);
			return true;
		}
		if (event.target == printEnv && event.id == Event.ACTION_EVENT) {
			printEnv_Clicked(event);
			return true;
		}
		if (event.target == LoadButton && event.id == Event.ACTION_EVENT) {
			LoadButton_Clicked(event);
			return true;
		}
		if (event.target == traceFlag && event.id == Event.ACTION_EVENT) {
			traceFlag_Action(event);
			return true;
		}
		if (event.target == loadButton2 && event.id == Event.ACTION_EVENT) {
			loadButton2_Clicked(event);
			return true;
		}
		if (event.target == addButton && event.id == Event.ACTION_EVENT) {
			addButton_Clicked(event);
			return true;
		}
		return super.handleEvent(event);
	}

	//{{DECLARE_CONTROLS
	java.awt.Label label2;
	java.awt.Label label1;
	java.awt.TextArea printArea;
	java.awt.Button evalButton;
	java.awt.TextArea readArea;
	java.awt.Label label3;
	java.awt.Button printEnv;
	java.awt.TextField sourceURL;
	java.awt.Label label4;
	java.awt.Button LoadButton;
	java.awt.Button addButton;
	java.awt.Button loadButton2;
	java.awt.Checkbox traceFlag;
	java.awt.Choice urlChoice;
	java.awt.Label label5;
	//}}
}