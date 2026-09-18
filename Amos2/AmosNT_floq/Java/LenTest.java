import callin.*;
import callout.*;

/**
  Example class.
  */
public class LenTest {


  /**
    Must have default constructor.
    */
  public LenTest() {
    // Put initializations here
  }

  /**
    Foreign function.
    Mesures the length of a string (CHARSTRING in AMOS2).
    */
  public void lenStr(CallContext cxt, Tuple tpl) throws AmosException {

    String str;

    // Pick up the argument
    try {
      str = tpl.getStringElem(0);

      // Calculate string length and emit result
      tpl.setElem(1, str.length());
      cxt.emit(tpl);
    }
    catch (AmosException e) {
      System.out.println(e);
      return;
    }

  }

  /**
    Foreign function.
    Mesures the length of a vector (Tuple).
    */
  public void lenVector(CallContext cxt, Tuple tpl) throws AmosException {

    try {
      // Pick up the argument
      Tuple tmpTpl = tpl.getSeqElem(0);

      // Calculate vector lentgh and emit result.
      tpl.setElem(1, tmpTpl.getArity());
      cxt.emit(tpl);
    }
    catch (AmosException e) {
      System.out.println(e);
      return;
    }

  }

}





