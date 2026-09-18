
import java.util.Random;
import java.io.*;

/**
 *  
 * @author Javad Bakhshi
 *
 **/


public class History_data{

 /**
 *      @param args[0] is the express way 
 *             args[1] is number of partitions
 **/

public static void main(String[] args) {
        int Xway = Integer.parseInt(args[0]);
        int Partitions  = Integer.parseInt(args[1]);
        int V_id = Xway*135000;
        Random Generator = new Random();

        try {
                FileWriter[] writers = new FileWriter[Partitions];
                for(int i=0; i<Partitions; i++)
                    writers[i] = new FileWriter("Historical_partition"+i);
                /* This create two partition data file. Add more if needed */

                String res="";
                int T;
                 for (int vid=1;vid<=V_id;vid++){
                    for (int day = 1; day <= 69; day++) {
                        int toll = Generator.nextInt(100);
                        int L = Generator.nextInt(Xway);
                        res=vid+","+ day+","+ L+","+ toll;
                        T = L%Partitions;
                        writers[T].write(res+"\n");
                                
                        }

                    }
                for (int j = 0;j<Partitions; j++)
                    writers[j].close();
                
                /* Add more closings here for more partitions */
            }
        catch (Exception e) {
            System.err.println("Exception: " + e.getMessage());
            }

        }
}
