import callin.*;
import callout.*;
import java.util.*;
import java.io.*;

public class Q_end {

    static Connection theConnection;

    public static String end(CallContext cxt, String sqlq) throws AmosException {


        Scan s;
        Tuple arg = new Tuple(1);
        Tuple arg1 = new Tuple(1);
        String q_end = "";
        String q_table = "";
        int p, q, r;

        Q_Vcol v = new Q_Vcol();
        String str1 = v.col(sqlq);
        String[] arr3 = str1.split(",");

        Q_Vtable t = new Q_Vtable();
        q_table = t.table(sqlq);
        String[] arr2 = q_table.split(",");

        if (str1.indexOf(".*") > -1) {
            String str6 = "";
            String str7 = "";
            r = 0;
            for (p = 0; p < arr3.length; p++) {
                for (q = 0; q < arr2.length; q++) {
                    if (arr3[p].substring(0,arr3[p].indexOf(".*")).equals(arr2[q].substring(arr2[q].indexOf(" ") + 1, arr2[q].length()))) {
                        arg1.setElem(0, arr2[q].substring(0, arr2[q].indexOf(" ")));
                        s = cxt.connection().callFunction("charstring.check_type1->charstring", arg1);
                        while (!s.eos()) {

                            str6 = "a" + r + "=vec[" + r + "]" + " and ";
                            str7 += str6;
                            r++;
                            s.nextRow();
                        }
                    }
                }
            }
            q_end = "and " + str7.substring(0, str7.length() - 5) + ";";
        } else if (str1.equals("*")) {
            int k;
            String str4 = "";
            String str5 = "";
            arg.setElem(0, arr2[0]);
            s = cxt.connection().callFunction("charstring.check_type1->charstring", arg);
            k = 0;
            while (!s.eos()) {
                str4 = "a" + k + "=vec[" + k + "]" + " and ";
                str5 += str4;
                k++;
                s.nextRow();
            }

            q_end = "and " + str5.substring(0, str5.length() - 5) + ";";
        } else {
            String[] arr = str1.split(",");
            int i;
            String str2 = "";
            String str3 = "";
            for (i = 0; i < arr.length; i++) {
                str2 = "a" + i + "=vec[" + i + "]" + " and ";
                str3 += str2;
            }
            q_end = "and " + str3.substring(0, str3.length() - 5) + ";";
        }
        return q_end;
    }
}
