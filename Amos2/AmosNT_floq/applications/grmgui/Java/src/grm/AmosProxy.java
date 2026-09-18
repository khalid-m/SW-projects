/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package grm;
import callin.*;
import javax.swing.JOptionPane;

/**
 *
 * @author andan342
 */
public class AmosProxy {
    public Connection conn;
    public Oid prereadFn, loadFn, getRulesFn, getTsFn, getNTsFn, getSetFn, getGroupedSetFn, getFollowsFn;
    public String grammar;

    public AmosProxy() {
        try {
            conn = new Connection("");
            prereadFn = conn.getFunction("charstring.preread_grammar->charstring.integer");
            loadFn = conn.getFunction("charstring.charstring.load_grammar->boolean");
            getRulesFn = conn.getFunction("CHARSTRING.GET_GRAMMAR_RULES->CHARSTRING.VECTOR-CHARSTRING.CHARSTRING");
            getTsFn = conn.getFunction("CHARSTRING.GET_GRAMMAR_TERMINALS->CHARSTRING");
            getNTsFn = conn.getFunction("CHARSTRING.GET_GRAMMAR_NTS->CHARSTRING");
            getSetFn = conn.getFunction("CHARSTRING.CHARSTRING.INTEGER.GET_GRAMMAR_SET->INTEGER.CHARSTRING.INTEGER"); //obsolete
            getGroupedSetFn = conn.getFunction("CHARSTRING.CHARSTRING.INTEGER.GET_GRAMMAR_GROUPED_SET->VECTOR-INTEGER.CHARSTRING.INTEGER");
            getFollowsFn = conn.getFunction("CHARSTRING.CHARSTRING.GET_GRAMMAR_FOLLOWS->CHARSTRING");
        } catch (AmosException e) { JOptionPane.showMessageDialog(null, e); }
    }
}
