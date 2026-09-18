
// used to get the parameters matched column
public class Get_column {

    public static String make(String sqlq) {
        int i;
        String str = "";
        String[] arr = sqlq.split(" ");
        String[] arr1 = sqlq.split(" ");
        for (i = 0; i < arr.length; i++) {
            int j;
            if (arr[i].indexOf(">=") > -1) {
                j = arr[i].indexOf("=");
                if (Character.isDigit(arr[i].charAt(j + 1)) || arr[i].indexOf("\"") > -1) {
                    arr1[i] = arr[i].replace(arr[i], "");
                } else {
                    arr1[i] = arr[i].substring(0, j - 1) + ",";
                }
            } else if (arr[i].indexOf("<=") > -1) {
                j = arr[i].indexOf("=");
                if (Character.isDigit(arr[i].charAt(j + 1)) || arr[i].indexOf("\"") > -1) {
                    arr1[i] = arr[i].replace(arr[i], "");
                } else {
                    arr1[i] = arr[i].substring(0, j - 1) + ",";
                }
            } else if (arr[i].indexOf(">") > -1) {
                j = arr[i].indexOf(">");
                if (Character.isDigit(arr[i].charAt(j + 1)) || arr[i].indexOf("\"") > -1) {
                    arr1[i] = arr[i].replace(arr[i], "");
                } else {
                    arr1[i] = arr[i].substring(0, j) + ",";
                }
            } else if (arr[i].indexOf("<") > -1) {
                j = arr[i].indexOf("<");
                if (Character.isDigit(arr[i].charAt(j + 1)) || arr[i].indexOf("\"") > -1) {
                    arr1[i] = arr[i].replace(arr[i], "");
                } else {
                    arr1[i] = arr[i].substring(0, j) + ",";
                }
            } else if (arr[i].indexOf("=") > -1) {
                j = arr[i].indexOf("=");
                if (Character.isDigit(arr[i].charAt(j + 1)) || arr[i].indexOf("\"") > -1) {
                    arr1[i] = arr[i].replace(arr[i], "");
                } else {
                    arr1[i] = arr[i].substring(j + 1, arr[i].length()) + ",";
                    if (arr1[i].indexOf(".") > -1) {
                        arr1[i] = arr[i].replace(arr[i], "");
                    } else {
                        arr1[i] = arr[i].substring(0, j) + ",";
                    }
                }
            } else {
                arr1[i] = arr[i].replace(arr[i], "");
            }
            str += arr1[i];

        }
        if (str.length() == 0) {
            str = "";
        } else {
            str = str.substring(0, str.length() - 1);
        }

        return str;

    }
}
