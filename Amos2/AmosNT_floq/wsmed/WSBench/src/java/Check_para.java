

public class Check_para {
    //match the table names for special parameters

    public static String fcheck(String sqlq) {
        int i, j, k, l, p, q, r, s;
        String str = "";
        String str1 = "";
        String str2 = "";
        String str3 = "";
        String str4 = "";

        Get_column m = new Get_column();
        str = m.make(sqlq);
        Get_table f = new Get_table();
        str1 = f.look(sqlq);
        String[] arr = sqlq.split("select");
        String[] arr1 = str.split(",");
        String[] arr2 = str1.split(",");
        String[] arr3 = new String[100];

        if (!str.equals("")) {
            if (str1.indexOf(" as ") > -1) {
                for (r = 0; r < arr1.length; r++) {
                    for (s = 0; s < arr2.length; s++) {
                        {
                            if (arr1[r].indexOf(arr2[s].substring(arr2[s].indexOf(" as ") + 4, arr2[s].length())) > -1) {
                                str4 = arr2[s].substring(0, arr2[s].indexOf(" as ")) + " " + arr1[r].substring(arr1[r].indexOf(".") + 1, arr1[r].length()) + ",";
                            } else {
                                str4 = "";
                            }
                            str2 += str4;
                        }

                    }
                }

            } else if (str.indexOf(".") > -1) {
                for (l = 0; l < arr1.length; l++) {
                    for (q = 0; q < arr2.length; q++) {
                        {
                            String checkStr=arr1[l].substring(0,arr1[l].indexOf("."));
                            String checkStr1=arr2[q].substring(arr2[q].indexOf(" ") + 1, arr2[q].length()).trim(); 
                            //System.out.println("checkStr >"+checkStr+"<");
                            //System.out.println("arr str >"+checkStr1+"<");
                            //if (arr1[l].indexOf(arr2[q].substring(arr2[q].indexOf(" ") + 1, arr2[q].length())) > -1) {
			    if (checkStr.equalsIgnoreCase(checkStr1)) {
                                str3 = arr2[q].substring(0, arr2[q].indexOf(" ")) + " " + arr1[l].substring(arr1[l].indexOf(".") + 1, arr1[l].length()) + ",";
			    } else {
                                str3 = "";
                            }
                            str2 += str3;
                        }

                    }
                }

            } else {
                for (i = 0; i < arr.length; i++) {
                    for (j = 0; j < arr2.length; j++) {
                        if (arr[i].indexOf(arr2[j]) > -1) {
                            for (k = 0; k < arr1.length; k++) {
                                if (arr[i].indexOf(arr1[k]) > -1) {
                                    arr3[i * arr2.length * arr.length + k] = arr2[j] + arr1[k] + ",";
                                } else {
                                    arr3[i * arr2.length * arr.length + k] = "";
                                }
                                str2 += arr3[i * arr2.length * arr.length + k];
                            }
                        } else {
                        }
                    }
                }
            }
            if (str2.indexOf(", ") > -1) {
                str2 = "";
            } else {
                str2 = str2.substring(0, str2.length() - 1);
            }
        } else {
            str2 = "";
        }
        return str2;
    }
}
