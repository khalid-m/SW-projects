package JavaAMOS;
import callin.*;
import callout.*;

/**
 * Title:        JavaAMOS
 * Description:  System foreign functions in Java
 * Copyright:    Copyright (c) 2003
 * Company:      UDBL - Uppsala University
 * @author Tore Risch
 * @version
 */

public class Foreign {

  public Foreign() {
  }
  /**
    * Foreign function to force Java GC
    */
  public void gc(CallContext cxt, Tuple tpl) throws AmosException {

      System.gc();
}
}