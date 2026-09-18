
import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Random;
import java.util.Scanner;

/**
 *
 * @author Javad Bakhshi
 */
public class History {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        Connection con = null;
        ResultSet rs = null;
        String Xway = args[0];
        String maxXway = args[1];
        String Direction = args[2];
        Random Generator = new Random();
        //System.out.println(args[0]);
        try {
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            con = 
DriverManager.getConnection("jdbc:mysql://localhost:3036/LRB",
                    "regress", "regress");

            String query = "INSERT INTO historical_toll values(?,?,?,?)";
            PreparedStatement ps = null;
            if (!con.isClosed()) {
                ps = con.prepareStatement(query);
                for (int vid=434176; vid<=Integer.parseInt(maxXway);vid++) {
                        for (int day = 1; day <= 69; day++) {
                            int toll = Generator.nextInt(100);
                            int Xway1 = 
Generator.nextInt(Integer.parseInt(Xway) + 1);
			    //System.out.println("xway =" + Xway1);
                            ps.setInt(1, vid);
                            ps.setInt(2, day);
                            ps.setInt(3, Xway1);
                            ps.setInt(4, toll);
                            ps.executeUpdate();

                        }
                    }
                }
            }

         catch (Exception e) {
            System.err.println("Exception: " + e.getMessage());
        } finally {
            try {
                if (con != null) {
                    
                    con.close();

                }
		if(rs != null){
		    rs.close();
		}

            } catch (SQLException e) {
                System.err.println("Exception: " + e.getMessage());
            }
        }
    }
}
