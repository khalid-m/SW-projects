/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package grm;

import callin.*;
import javax.swing.JList;
import javax.swing.tree.TreePath;

/**
 *
 * @author andan342
 */
public class GrammarRuleSymbol {
    public int[] rules;
    public String symbol;
    public int tag;
    public boolean nt;    
    public TreePath original = null;
    public JList list;


    public GrammarRuleSymbol(Tuple rulesVector, String symbol, int tag, boolean nt, JList list) throws AmosException {
        rules = new int[rulesVector.getArity()];
        for (int i=0; i<rules.length; i++) rules[i] = rulesVector.getIntElem(i);
        this.symbol=symbol;
        this.tag=tag;
        this.nt=nt;
        this.list = list;
    }

    public String tag2label(int tag) {
        if (tag==1) return "follows";
        else if (tag==2) return "starts";
        return "ends";
    }

    @Override public String toString() {
        boolean sel = SymbolSeqRenderer.member(symbol, list.getSelectedValues());

        StringBuffer sb = new StringBuffer("<html>");
        if (sel) sb.append("<font style=\"BACKGROUND-COLOR: yellow\">");
        if (tag==3) sb.append("<font color=\"#008000\">"); //paint IDE nodes in green
        sb.append("(" + tag2label(tag) + ":");
        for (int i=0; i<rules.length; i++) sb.append(" " + rules[i]);
        sb.append(") ");
        if (original!=null) { //paint duplicate NTs in blue (or bright-green)
            if (tag==3) sb.append("<font color=\"#00D000\">");
            else sb.append("<font color=\"#0000FF\">");
        }
        if (!nt) sb.append("<b>");
        SymbolSeqRenderer.writeHTML(symbol, sb);
        if (!nt) sb.append("</b>");
        if (original!=null) sb.append("</font>");
        if (tag==3) sb.append("</font>");
        if (sel) sb.append("</font>");
        return sb.toString();
    }
}
