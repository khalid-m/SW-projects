/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package grm;

import javax.swing.table.DefaultTableModel;

/**
 *
 * @author andan342
 */
public class RulesTableModel extends DefaultTableModel {

    public RulesTableModel(Object[] columnNames, int rowCount) {
        super(columnNames, rowCount);
    }

     @Override public Class getColumnClass(int c) {
            return getValueAt(0, c).getClass();
        }
}
