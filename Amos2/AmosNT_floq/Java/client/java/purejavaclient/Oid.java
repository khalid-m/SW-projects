package udbl.amos.purejavaclient;

import java.io.IOException;

public class Oid extends Atom{
    public volatile int oidtypeHandle;
    public volatile Connection theConnection;
    public volatile int typeTag;
    public String name = null;
    private String typename = null;
    public Oid()
    {
    	super();
    }

    @SuppressWarnings("unused")
	private Oid(int oidtype, int typetag, Connection theConnection) {
		this.theConnection = theConnection;
		this.oidtypeHandle = oidtype;
		this.typeTag = typetag;
    }
    public Oid(int oidtypeHandle){
    	this.oidtypeHandle = oidtypeHandle;
    }
    public Oid(String oidName, int oidHandle){
    	this.oidtypeHandle=oidHandle;
    	this.name=oidName;
    }
    protected void finalize() {
    	this.finalize();
    }
    public boolean equals(Object theObject) 
    {
    	return ((theObject instanceof Oid) && (this.oidtypeHandle == ((Oid)theObject).oidtypeHandle));
    }
    public final String getTypename()  throws IOException, Exception{
    	if (this.typename == null)
	    {
    		this.typename = null;//this.getConnection().callFunction("typename", this).getRow().getStringElem(0);
	    }
		return (this.typename);
    }
    public Connection getConnection()
    {
		if(this.theConnection!=null) 
			return this.theConnection;
//		else 
	//		return Connection.localConnection();
		return null;
    }
    public String getName()  throws AmosException{
		Scan sc=null;
		Tuple tp=null;
		if (this.name == null || this.name.equals("")) {
			try {
				sc=this.theConnection.callFunction("typeof", this);
			}  catch (AmosException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			tp=sc.getRow();
			this.name=tp.getStringElem(0);
		}
		return (this.name);
    }
    public String toAmosString(){
    	return null;
    }
    
    public final String toString(){
		String msg = null;
		try {
			msg = this.getName();
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	    msg = (msg.equals("")) ? msg : " \"" + msg+ "\"";
	    try {
			msg = "#[OID " + this.getID() + msg + "]";
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return (msg);
    }
    public Oid CopyProps(Oid o){
       this.typename = o.typename;
       this.name = o.name;
       this.theConnection = o.theConnection;
       this.oidtypeHandle = o.oidtypeHandle;
       this.typeTag = o.typeTag;
       return o;
    }
    public int getID()  throws AmosException{
    	return this.oidtypeHandle;
    }
	public void print() {
		System.out.println("(#[OID "+this.oidtypeHandle+" \""+this.name+"\"])");
	}

	public void delete() throws AmosException {
		this.theConnection.callFunction("deleteobject", this);
	}

	public String getType() throws AmosException {
		Scan sc=null;
		Tuple tp=null;
		sc=this.theConnection.callFunction("typeof", this);
		tp=sc.getRow();
		return tp.getStringElem(0);
	}
}
