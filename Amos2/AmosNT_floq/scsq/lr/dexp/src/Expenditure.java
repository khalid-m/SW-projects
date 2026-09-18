
import java.io.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 *
 * @author Jahvad Bakhshi
 */
public class Expenditure {

    public static void main(String[] args) {
        Connection con = null;
        BufferedReader in = null;

        String Xway = "";
        String QID = "";
        String Day = "";
        String VID = "";
        String Time = "";
        String Type = "";
	long start=0;
        int Toll=0;

        if (args.length != 1) {
            System.err.println("missing filename");
            System.exit(1);
        }
        try {
            in = new BufferedReader(new FileReader(args[0]));
            try {
                Class.forName("com.mysql.jdbc.Driver").newInstance();
                con = DriverManager.getConnection("jdbc:mysql://tintin1.uppmax.uu.se:3036/LRB128","regress", "regress");
                String query = "SELECT toll FROM historical_toll WHERE vid=? AND day=? AND xway=?";
                PreparedStatement ps = null;
                ResultSet rs = null;
                String str;
                while ((str = in.readLine()) != null) {
		    start=System.nanoTime();
                    String[] strArr = str.split(" ");
                    if (strArr[0].equals("#(3")) {
                        Type = "3";
                        Time = strArr[1];
                        VID = strArr[2];
                        Xway = strArr[4];
                        QID = strArr[9];
                        Day = strArr[14].replace(")", "");


                        if (!con.isClosed()) {
                            ps = con.prepareStatement(query);
                            ps.setInt(1, Integer.parseInt(VID));
                            ps.setInt(2, Integer.parseInt(Day));
                            ps.setInt(3, Integer.parseInt(Xway));
                            rs = ps.executeQuery();
                            if(rs.next()){
                               Toll=rs.getInt(1);
			       long curentSec=System.nanoTime()-start;
                               System.out.println("#(3 "+Time+" "+curentSec+" "+QID+" "+Toll+")");
			       
                            }

                        }
                    }
                }

            } catch (Exception e) {
                System.err.println("Exception: " + e.getMessage());
            } finally {
                try {
                    if (con != null) {
                        con.close();
                    }
                } catch (SQLException e) {
                    System.err.println("Exception: " + e.getMessage());
                }
            }
            in.close();
        } catch (IOException e) {
            System.err.println(e);
        } finally {
            try {
                in.close();
            } catch (IOException ex) {
                System.err.println("Exception: " + ex.getMessage());
            }
        }



    }
}
