package bigtable;
import java.util.ArrayList;


/**
 * A couple of helper functions to create formatted output from Arrays
 */
public class ResultFormater {
	
    private ResultFormater(){
    }
	
    public static String arrayToString(Object[] a, String separator) {
	if (a.length > 0) {
	    StringBuilder result = new StringBuilder(a[0].toString());
	    for (int i=1; i<a.length; i++) {
		result.append(separator);
		result.append(a[i].toString());
	    }
	    return result.toString();
	}
	return "";
    }
	
    @SuppressWarnings("unchecked")
	public static String arrayToString(ArrayList a, String separator) {
	if (a.size() > 0) {
	    StringBuilder result = new StringBuilder(a.get(0).toString());
	    for (int i=1; i<a.size(); i++) {
		result.append(separator);
		result.append(a.get(i).toString());
	    }
	    return result.toString();
	}
	return "";
    }

    @SuppressWarnings("unchecked")
	public static String arraysToString(String formatString, String separator, ArrayList<String> a) {
	return ResultFormater.arraysToString(formatString, separator, new ArrayList[]{a});
    }

    @SuppressWarnings("unchecked")
	public static String arraysToString(String formatString, String separator, ArrayList<String> a, ArrayList<String> b) {
	return ResultFormater.arraysToString(formatString, separator, new ArrayList[]{a ,b});
    }

    public static String arraysToString(String formatString, String separator, ArrayList<String>[] a) {
	if ( a.length>0 ) {
	    StringBuilder result=new StringBuilder();
	    int i=0;
	    Object[] params = new String[a.length];
	    while(true){
		for (int s=0; s<a.length; s++){
		    if(a[s].size()<=i)
			return result.toString();
		    params[s] = (a[s].get(i)!=null)? a[s].get(i) : "";
		}
		if(i>0) result.append(separator);
		result.append( String.format(formatString, params) );
		i++;
	    }
	}
	return "";
    }
}
