/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package grm;

import javax.swing.table.DefaultTableCellRenderer;
import callin.*;
import javax.swing.JOptionPane;

/**
 *
 * @author andan342
 */
public class SymbolSeqRenderer extends DefaultTableCellRenderer {

    public GRMView viewForm;

    public SymbolSeqRenderer(GRMView viewForm) {
        super();
        this.viewForm = viewForm;
    }

    public static boolean member(String symbol, Object[] symbols) {
        for (int i=0; i < symbols.length; i++)
            if (symbol.equals(symbols[i])) {
                return true;
            }
        return false;
    }

    public static void writeHTML(String s, StringBuffer sb) {
        for (int i=0; i<s.length(); i++) {
            if (s.charAt(i)=='<') sb.append("&lt;");
            else if (s.charAt(i)=='>') sb.append("&gt;");
            else sb.append(s.charAt(i));
        }
    }

    @Override public void setValue(Object value) {
        Tuple seq = (Tuple)value;
        StringBuffer sb = new StringBuffer();

        try {
            for (int i=0; i<seq.getArity(); i++) {
                String symbol = seq.getStringElem(i);
                boolean isT = member(symbol,viewForm.tsModel.toArray());
                boolean selT = member(symbol,viewForm.tsList.getSelectedValues());
                boolean selNT = member(symbol,viewForm.ntsList.getSelectedValues());

                if (sb.length() > 0) sb.append(" ");
                if (selT) sb.append("<font style=\"BACKGROUND-COLOR: yellow\">");
                else if (selNT) sb.append("<font style=\"BACKGROUND-COLOR: #FFA0FF\">");
                if (isT) sb.append("<b>");
                writeHTML(symbol,sb);
                if (isT) sb.append("</b>");
                if (selT || selNT) sb.append("</font>");
            }
        } catch (AmosException e) { JOptionPane.showMessageDialog(null, e); }
        setText("<html>" + sb.toString());
    }
/*
    @Override public Component getTableCellRendererComponent(
                                JTable table, Object seq,
                                boolean isSelected, boolean hasFocus,
                                int row, int column) {
        setValue(seq);
        return this;
    }*/
}
