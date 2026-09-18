package imgproc;

/**
 * CJProxy is the Java side of the C-to-Java JNI interface.
 * Classes that implement CJProxy implement the command pattern
 */
public interface CJProxy
{
   public Object extract(Object args) throws Exception;
   public Object display(Object args) throws Exception;
}

