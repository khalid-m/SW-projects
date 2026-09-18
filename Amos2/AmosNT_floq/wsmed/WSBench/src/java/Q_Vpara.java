
import callin.*;
import callout.*;
import java.util.*;
import java.io.*;

//used to get the type of the parameters
public class Q_Vpara {

    static Connection theConnection;

    public static String compos(CallContext cxt, String sqlq) throws AmosException {

        int i, j, x, k, m, l, n, p, q, r;
        Scan s;
        Tuple arg1 = new Tuple(2);
        Tuple arg2 = new Tuple(2);
        Tuple arg3 = new Tuple(1);
        Tuple arg4 = new Tuple(2);
        Tuple arg5 = new Tuple(2);
        Tuple arg6 = new Tuple(1);
        String col = "";
        String q_table = "";
        String q_para = "";
        String para = "";

        Q_Vcol v = new Q_Vcol();
        col = v.col(sqlq);

        Q_Vtable t = new Q_Vtable();
        q_table = t.table(sqlq);
        String[] arr1 = q_table.split(",");

        if (col.indexOf(".*") > -1) {
            String str21 = "";
            String str22 = "";
            String str23 = "";
            String str24 = "";
            String[] arr5 = col.split(",");
            r = 0;
            for (p = 0; p < arr5.length; p++) {
                for (q = 0; q < arr1.length; q++) {
                    if (arr5[p].substring(0,arr5[p].indexOf(".*")).equals(arr1[q].substring(arr1[q].indexOf(" ") + 1, arr1[q].length())) ) {
                        arg6.setElem(0, arr1[q].substring(0, arr1[q].indexOf(" ")));
                        s = cxt.connection().callFunction("charstring.check_type1->charstring", arg6);

                        while (!s.eos()) {
                            Tuple row;
                            row = s.getRow();
                            str21 = row.getStringElem(0);
                            if (str21.equals("int")) {
                                str21 = "Integer";
			    }  else if (str21.equals("double")) {
                                str21 = "Real";
                            } else if (str21.equals("char") || str21.equals("varchar")) {
                                str21 = "Charstring";
                            } else {
                                str21 = "Charstring";
                            }
                            str22 = str21 + " a" + r + ",";
                            str23 = "a" + r + ",";
                            r++;
                            para += str22;
                            str24 += str23;
                            s.nextRow();
                        }
                        para = para.substring(0, para.length() - 1);
                        str24 = str24.substring(0, str24.length() - 1);
                    }
                }
            }
            q_para = "<" + para + "> as select " + str24 + " from vector vec where vec=";
        } else if (col.equals("*")) {
            String[] arr3 = col.split(",");
            String str9 = "";
            String str10 = "";
            String str11 = "";
            String str12 = "";
            arg3.setElem(0, arr1[0]);
            s = cxt.connection().callFunction("charstring.check_type1->charstring", arg3);
            x = 0;
            while (!s.eos()) {
                Tuple row1;
                row1 = s.getRow();
                str9 = row1.getStringElem(0);
                if (str9.equals("int")) {
                    str9 = "Integer";
		}
		else if (str9.equals("double")) {
                    str9 = "Real";
                } else if (str9.equals("char") || str9.equals("varchar")) {
                    str9 = "Charstring";
                } else {
                    str9 = "Charstring";
                }
                str10 = str9 + " a" + x + ",";
                str11 = "a" + x + ",";
                x++;
                para += str10;
                str12 += str11;
                s.nextRow();
            }
            para = para.substring(0, para.length() - 1);
            str12 = str12.substring(0, str12.length() - 1);
            q_para = "<" + para + "> as select " + str12 + " from vector vec where vec=";
        } else if (col.indexOf(".") > -1) {
            ///////////////////////deal with join//////////
            if (q_table.indexOf(" as ") > -1) {
                String[] arr3 = col.split(",");
                String str13 = "";
                String str14 = "";
                String str15 = "";
                String str16 = "";
                for (l = 0; l < arr3.length; l++) {
                    for (n = 0; n < arr1.length; n++) {
                        if (arr3[l].indexOf(arr1[n].substring(arr1[n].indexOf("as") + 3, arr1[n].length())) > -1) {
                            arg4.setElem(0, arr1[n].substring(0, arr1[n].indexOf("as") - 1));
                            arg4.setElem(1, arr3[l].substring(arr3[l].indexOf(".") + 1, arr3[l].length()));
                            s = cxt.connection().callFunction("charstring.charstring.check_type->charstring", arg4);
                            str13 = s.getRow().getStringElem(0);
                            if (str13.equals("int")) {
                                str13 = "Integer";
                            } else  if (str13.equals("double")) {
                                str13 = "Real";
                            } else if (str13.equals("char") || str13.equals("varchar")) {
                                str13 = "Charstring";
                            } else {
                                str13 = "Charstring";
                            }
                            str14 = str13 + " a" + l + ",";
                            str15 = "a" + l + ",";
                            para += str14;
                            str16 += str15;
                        }
                    }
                }
                para = para.substring(0, para.length() - 1);
                str16 = str16.substring(0, str16.length() - 1);
                q_para = "<" + para + "> as select " + str16 + " from vector vec where vec=";
            } else if (q_table.indexOf(" ") > -1) {
                String[] arr4 = col.split(",");
                String str17 = "";
                String str18 = "";
                String str19 = "";
                String str20 = "";
                for (k = 0; k < arr4.length; k++) {
                    for (m = 0; m < arr1.length; m++) {

                        if (arr4[k].indexOf(arr1[m].substring(arr1[m].indexOf(" ") + 1, arr1[m].length())) > -1) {
                            arg5.setElem(0, arr1[m].substring(0, arr1[m].indexOf(" ")));
                            arg5.setElem(1, arr4[k].substring(arr4[k].indexOf(".") + 1, arr4[k].length()));
                            s = cxt.connection().callFunction("charstring.charstring.check_type->charstring", arg5);
                            str17 = s.getRow().getStringElem(0);
                            if (str17.equals("int")) {
                                str17 = "Integer";
			    } else if (str17.equals("double")) {
                                str17 = "Real";
			    } else if (str17.equals("char") || str17.equals("varchar")) {
                                str17 = "Charstring";
                            } else {
                                str17 = "Charstring";
                            }
                            str18 = str17 + " a" + k + ",";
                            str19 = "a" + k + ",";
                            para += str18;
                            str20 += str19;
                        }
                    }
                }
                para = para.substring(0, para.length() - 1);
                str20 = str20.substring(0, str20.length() - 1);
                q_para = "<" + para + "> as select " + str20 + " from vector vec where vec=";

            } else {
                String[] arr2 = col.split(",");
                String str5 = "";
                String str6 = "";
                String str7 = "";
                String str8 = "";
                for (j = 0; j < arr2.length; j++) {
                    arg2.setElem(0, arr2[j].substring(0, arr2[j].indexOf(".")));
                    arg2.setElem(1, arr2[j].substring(arr2[j].indexOf(".") + 1, arr2[j].length()));
                    s = cxt.connection().callFunction("charstring.charstring.check_type->charstring", arg2);
                    str5 = s.getRow().getStringElem(0);
                    if (str5.equals("int") || str5.equals("double")) {
                        str5 = "Integer";
                    } else if (str5.equals("char") || str5.equals("varchar")) {
                        str5 = "Charstring";
                    } else {
                        str5 = "Charstring";
                    }
                    str6 = str5 + " a" + j + ",";
                    str7 = "a" + j + ",";
                    para += str6;
                    str8 += str7;
                }
                para = para.substring(0, para.length() - 1);
                str8 = str8.substring(0, str8.length() - 1);
                q_para = "<" + para + "> as select " + str8 + " from vector vec where vec=";
            }
        } else {
            String[] arr = col.split(",");
            String str1 = "";
            String str2 = "";
            String str3 = "";
            String str4 = "";
            for (i = 0; i < arr.length; i++) {
                arg1.setElem(0, arr1[0]);
                arg1.setElem(1, arr[i]);
                s = cxt.connection().callFunction("charstring.charstring.check_type->charstring", arg1);
                str1 = s.getRow().getStringElem(0);
                if (str1.equals("int") || str1.equals("double")) {
                    str1 = "Integer";
                } else if (str1.equals("char") || str1.equals("varchar")) {
                    str1 = "Charstring";
                } else {
                    str1 = "Charstring";
                }
                str2 = str1 + " a" + i + ",";
                str3 = "a" + i + ",";
                para += str2;
                str4 += str3;

            }

            para = para.substring(0, para.length() - 1);
            str4 = str4.substring(0, str4.length() - 1);
            q_para = "<" + para + "> as select " + str4 + " from vector vec where vec=";
        }

        return q_para;

    }
}
