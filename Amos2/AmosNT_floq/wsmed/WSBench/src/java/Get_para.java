import java.lang.Character.*;

//the way to find out the parameters of a query from the sql query
public class Get_para {

    public static String get(String sqlq) {
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
                    arr1[i] = arr[i].substring(j + 2, arr[i].length()) + ",";
                }
            } else if (arr[i].indexOf("<=") > -1) {
                j = arr[i].indexOf("=");
                if (Character.isDigit(arr[i].charAt(j + 1)) || arr[i].indexOf("\"") > -1) {
                    arr1[i] = arr[i].replace(arr[i], "");
                } else {
                    arr1[i] = arr[i].substring(j + 2, arr[i].length()) + ",";
                }
            } else if (arr[i].indexOf(">") > -1) {
                j = arr[i].indexOf(">");
                if (Character.isDigit(arr[i].charAt(j + 1)) || arr[i].indexOf("\"") > -1) {
                    arr1[i] = arr[i].replace(arr[i], "");
                } else {
                    arr1[i] = arr[i].substring(j + 2, arr[i].length()) + ",";
                }
            } else if (arr[i].indexOf("<") > -1) {
                j = arr[i].indexOf("<");
                if (Character.isDigit(arr[i].charAt(j + 1)) || arr[i].indexOf("\"") > -1) {
                    arr1[i] = arr[i].replace(arr[i], "");
                } else {
                    arr1[i] = arr[i].substring(j + 2, arr[i].length()) + ",";
                }
            } else if (arr[i].indexOf("=") > -1) {
                j = arr[i].indexOf("=");
                if (Character.isDigit(arr[i].charAt(j + 1)) || arr[i].indexOf("\"") > -1) {
                    arr1[i] = arr[i].replace(arr[i], "");
                } else {
                    arr1[i] = arr[i].substring(j + 2, arr[i].length()) + ",";
                    if (arr1[i].indexOf(".") > -1) {
                        arr1[i] = arr[i].replace(arr[i], "");
                    } else {
                    }
                }
            } else {
                arr1[i] = arr[i].replace(arr[i], "");
            }
            str += arr1[i];

        }

        if (str.length() == 0) {
            str = "";
        } else if (str.indexOf("),") > -1) {
            str = str.replace("),", "");
        } else {
            str = str.substring(0, str.length() - 1);
        }
        return str;

    }
}
