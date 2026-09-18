
import java.io.*;

public class Delete {

    public static void delete(String del) throws IOException {
        File f = new File(System.getenv("AMOS_HOME") + "wsmed/WSBench/src/amosql/user_defined.amosql");
        File f1 = new File(System.getenv("APACHE_HOME") + "/www/information/user_defined.txt");
        File f2 = new File(System.getenv("AMOS_HOME")+"wsmed/WSBench/src/amosql/user_defined_wsop.amosql");
        BufferedReader br = null;
        BufferedReader br1 = null;
        BufferedReader br2 = null;
        StringBuilder sb = new StringBuilder();
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        try {
            br = new BufferedReader(new FileReader(f));
            String line;

            while ((line = br.readLine()) != null) {
                if (line.indexOf(del) != -1) {
                    line = "";
                } else {
                    line = line+"\r\n";
                }
                sb.append(line);
            }
            br.close();

            BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(f)));
            bw.write(sb.toString());
            bw.close();
        } catch (IOException e) {
        }

        try {
            br1 = new BufferedReader(new FileReader(f1));
            String line1;

            while ((line1 = br1.readLine()) != null) {
                if (line1.indexOf(del) != -1) {
                    line1 = "";
                } else { line1 = line1+"\r\n";
                }
                sb1.append(line1);
            }
            br1.close();

            BufferedWriter bw1 = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(f1)));
            bw1.write(sb1.toString());
            bw1.close();
        } catch (IOException e) {
        }

        try {
            br2 = new BufferedReader(new FileReader(f2));
            String line2;

            while ((line2 = br2.readLine()) != null) {
                if (line2.indexOf("ws"+del) != -1) {
                    line2 = "";
                } else {
                    line2 = line2+"\r\n";
                }
                sb2.append(line2);
            }
            br2.close();

            BufferedWriter bw2 = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(f2)));
            bw2.write(sb2.toString());
            bw2.close();
        } catch (IOException e) {
        }

    }
}
