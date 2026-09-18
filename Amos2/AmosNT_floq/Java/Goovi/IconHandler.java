package Goovi;

import java.awt.*;
import java.util.*;
import jclass.util.*;

/**
  * Class for handling Goovi icons.
  *
  * @author Kristofer Cassel
  */
public class IconHandler {

public static void init()
{
  JCImageCreator im = new JCImageCreator(new Frame(), 20, 21);
  for (int i=0; i < typeNames.length; i++)
  {
    im.setColor( 'o', colors[i]          );
    im.setColor( 'p', colors[i].darker() );
    im.setColor( '-', Color.black        );
    im.setColor( 'b', Color.blue.brighter() );
    im.setColor( 'w', Color.white        );
    Images.put(typeNames[i], im.create ( bitmaps[iconnumber[i]] ));
  }// end for
}// end init

/**
  * Gets an icon for the specified type.
  *
  * @parameter typeName  Gets an icon for the specified type
  * @returns An image with the icon.
  */
public static Image getIcon(String typeName)
{
  Image im = (Image)(Images.get(typeName.toUpperCase()));
  if (im == null) return (Image)(Images.get("%other%"));
  return im;
}

private static final int  BOX = 0, COLLECTION = 2, STRING = 4,INTEGER = 5, DOUBLE = 6,
                         AMOS = 7, ERROR = 8, NOICON = 1, FUNCTION = 3, ARGUMENT = 9,
                         RESULT = 10, ATTRIBUTE = 11, NIL = 12;

private final static String[] typeNames =
{
  "STOREDTYPE", "DERIVEDTYPE", "TYPE" , "COLLECTION", "INTEGER",
  "DOUBLE", "CHARSTRING", "ERROR", "NOICON", "PROXYTYPE",
  "USERTYPE", "FUNCTION", "ARGUMENT", "RESULT", "ATTRIBUTE",
  "NIL", "IUT", "AMOS", "RELATIONAL", "DTD", "STEP",
  "ODBC", "JDBC", "DATASOURCE", "%other%"
};

private final static Color[] colors     =
{
  Color.yellow, Color.orange, Color.yellow.darker(), Color.yellow, Color.red,
  Color.green , Color.yellow, Color.red, Color.red, Color.green,
  Color.yellow, Color.green, Color.yellow, Color.yellow, Color.orange,
  Color.black, Color.green, Color.lightGray, Color.yellow, Color.orange, Color.green,
  Color.cyan, Color.magenta, Color.blue, Color.red
};

private final static int[] iconnumber     =
{
  BOX, BOX, BOX, COLLECTION, INTEGER,
  DOUBLE, STRING, ERROR, NOICON, BOX,
  BOX, FUNCTION, ARGUMENT, RESULT, ATTRIBUTE,
  NIL, BOX, AMOS, AMOS, AMOS, AMOS,
  AMOS, AMOS, AMOS, BOX
};

private static HashMap Images = new HashMap();

private static final String bitmaps[][] ={

// box closed #0
{
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"      ---------     ",
"     --ooooooo-     ",
"    -p-oooooo--     ",
"   ----------p-     ",
"   -ooooooo-pp-     ",
"   -ooooooo-pp-     ",
"   -ooooooo-pp-     ",
"   -ooooooo-pp-     ",
"   -ooooooo-pp-     ",
"   -ooooooo-p-      ",
"   -ooooooo--       ",
"   ---------        ",
"                    ",
"                    ",
"                    ",
"                    "
},

// noicon #1
{
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    "
},

// collection open #2
{
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"    op-      op-    ",
"   op-        op-   ",
"  op-          op-  ",
" op-            op- ",
"op-              op-",
" op-            op- ",
"  op-          op-  ",
"   op-        op-   ",
"    op- -- --op-    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    "
},

// function #3
{
"                    ",
"                    ",
"        p           ",
"       opo-         ",
"      op-op-        ",
"      op- p-        ",
"      op-           ",
"      op-           ",
"      op-           ",
"   oopppppp-        ",
"    --op----        ",
"      op-           ",
"      op-           ",
"      op-           ",
"      op-           ",
"      op-           ",
"      op-           ",
"      op-           ",
"     op-            ",
"                    ",
"                    "
},

// string #4
{
"                    ",
"                    ",
"                    ",
"     op-            ",
"    opp-            ",
"   oppp-            ",
" oppppppp-          ",
"   oppp-            ",
"   oppp-            ",
"   oppp-            ",
"   oppp-            ",
"   oppp-            ",
"   oppp-            ",
"   oppp-  op        ",
"   oppp- op-        ",
"    oppppp-         ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    "
},

// integer #5
{
"                    ",
"                    ",
"                    ",
"                    ",
"      op      op    ",
"      op      op    ",
"      op      op    ",
"     op      op     ",
"  opppppppppppppp-  ",
"     op     op      ",
"     op     op      ",
" opppppppppppppp-   ",
"    op      op      ",
"   op      op       ",
"   op      op       ",
"   op      op       ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    "
},

// float #6
{
"                    ",
"                    ",
"                    ",
"                    ",
"  op op             ",
"  op op             ",
"   opp              ",
"   opp    op        ",
"  op op  op         ",
"  op op  op         ",
"        op          ",
"       op   op  op  ",
"       op   op  op  ",
"      op     opop   ",
"              op    ",
"             op     ",
"             op     ",
"                    ",
"                    ",
"                    ",
"                    "
},

// amos #7
{
"                    ",
"                    ",
"                    ",
"                    ",
"   ppppppppppppo    ",
"   poooooooooopo    ",
"   pobbbbbbbbbpo    ",
"   pob  bbbbbbpo    ",
"   pob bbbbbbbpo    ",
"   pobbbbbbbbbpo    ",
"   pobbbbbbbbbpo    ",
"   pobbbbbbbbbpo    ",
"   pobbbbbbbbbpo    ",
"   ppppppppppppo    ",
"   ppppppppppppo    ",
"   pwwwwwwwwwwwwo   ",
"  pwppppppppwpppwo  ",
" pwwwwwwwwwwwwwwwwo ",
"pppppppppppppppppppo",
"                    ",
"                    "
},
// error #8
{
"                    ",
"                    ",
"                    ",
"                    ",
"      ---------     ",
"    --ooooooooo--   ",
"   -ooooooooooooo-  ",
"  -oooowwooowwoooo- ",
"  -ooooowwowwooooo- ",
"  -oooooowwwoooooo- ",
"  -oooooowwwoooooo- ",
"  -oooooowwwoooooo- ",
"  -ooooowwowwooooo- ",
"  -oooowwooowwoooo- ",
"   -ooooooooooooo-  ",
"    --ooooooooo--   ",
"      ---------     ",
"                    ",
"                    ",
"                    ",
"                    "
},

// Argument #9
{
"                    ",
"                    ",
"            p       ",
"           opo-     ",
"          op-op-    ",
"          op- p-    ",
"          op-       ",
"   -      op-       ",
"   --     op-       ",
"------ oopppppp-    ",
"------- --op----    ",
"------    op-       ",
"   --     op-       ",
"   -      op-       ",
"          op-       ",
"          op-       ",
"          op-       ",
"          op-       ",
"         op-        ",
"                    ",
"                    "
},

// Result #10
{
"                    ",
"                    ",
"      p             ",
"     opo-           ",
"    op-op-          ",
"    op- p-          ",
"    op-             ",
"    op-       -     ",
"    op-       --    ",
" oopppppp- ------   ",
"  --op---- -------  ",
"    op-    ------   ",
"    op-       --    ",
"    op-       -     ",
"    op-             ",
"    op-             ",
"    op-             ",
"    op-             ",
"   op-              ",
"                    ",
"                    "
},

// Attribute #11
{
"         --         ",
"         --         ",
"         --         ",
"         --         ",
"      --------      ",
"       ------       ",
"      ---------     ",
"     --oo--ooo-     ",
"    -p-oooooo--     ",
"   ----------p-     ",
"   -ooooooo-pp-     ",
"   -ooooooo-pp-     ",
"   -ooooooo-pp-     ",
"   -ooooooo-pp-     ",
"   -ooooooo-pp-     ",
"   -ooooooo-p-      ",
"   -ooooooo--       ",
"   ---------        ",
"                    ",
"                    ",
"                    "
},

// Nil #12
{
"                    ",
"                    ",
"                    ",
"                    ",
"                    ",
"   ------------     ",
"   -         --     ",
"   -        - -     ",
"   -       -  -     ",
"   -      -   -     ",
"   -     -    -     ",
"   -    -     -     ",
"   -   -      -     ",
"   -  -       -     ",
"   - -        -     ",
"   ------------     ",
"                    ",
"                    ",
"                    ",
"                    ",
"                    "
},



}; // end bitmaps





}// end IconHandler
