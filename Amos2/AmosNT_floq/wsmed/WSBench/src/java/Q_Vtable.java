public class Q_Vtable {
    public static String table(String sqlq){
    String q_table;
    String[] arr=sqlq.split("from");
    if(arr[1].indexOf("where")>-1)
    { String[] arr1=arr[1].split("where");
    q_table=arr1[0].substring(1, arr1[0].length()- 1);}
    else 
    { q_table=arr[1].substring(1, arr[1].length());}

    return q_table;

}
}
