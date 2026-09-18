public class Q_Vcol {

    public static String col(String sqlq) {
        String q_head;
        String[] arr = sqlq.split("from");
        String[] arr1 = arr[0].split(" ");
        if (arr1[1].indexOf("distinct") > -1) {
            q_head = arr1[2];
        } else {
            q_head = arr1[1];
        }

        return q_head;
    }
}
