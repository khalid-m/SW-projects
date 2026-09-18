/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package grm;

/**
 *
 * @author andan342
 */
public class SymbolEntries {

    public String s;
    public int i;

    public SymbolEntries(String s, int i) {
        this.s = s;
        this.i = i;
    }

    public String toString() {
        return s + " (" + i + " entries)";
    }


}
