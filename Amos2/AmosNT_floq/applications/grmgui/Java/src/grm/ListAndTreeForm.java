/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * ListAndTreeForm.java
 *
 * Created on 2012-jan-19, 11:07:18
 */

package grm;

import java.awt.Component;
import javax.swing.DefaultListModel;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;

import callin.*;
import java.util.Enumeration;
import javax.swing.JOptionPane;
import javax.swing.tree.TreeNode;
import javax.swing.tree.TreePath;

/**
 *
 * @author andan342
 */
public class ListAndTreeForm extends javax.swing.JFrame {

    public AmosProxy ap;

    public DefaultListModel listModel = new DefaultListModel();
    
    public DefaultMutableTreeNode top = new DefaultMutableTreeNode();
    public DefaultTreeModel treeModel = new DefaultTreeModel(top);

    /** Creates new form ListAndTreeForm */
    public ListAndTreeForm() {
        initComponents();
    }

    public ListAndTreeForm(AmosProxy ap, String x, Component parent) {
        initComponents();
        this.ap = ap;
        setTitle("NEXT(" + x + ")");

        try {
            //1. Populate tree
            top.setUserObject(x);
            addNodes(top,null,x,1); //add all is-directly-followed-by nodes
            addNodes(top,null,x,3); //add all is-direct-end-of nodes
            for (int i=0; i<tree.getRowCount(); i++) tree.expandRow(i);
            tree.updateUI();

            //2. Populate list
            Tuple arg = new Tuple(2);
            arg.setElem(0, ap.grammar);
            arg.setElem(1, x);
            Scan scan = ap.conn.callFunction(ap.getFollowsFn, arg);
            while (!scan.eos()) {
                listModel.addElement(scan.getRow().getStringElem(0));
                scan.nextRow();
            }

        } catch (AmosException e) {JOptionPane.showMessageDialog(null, e); }
        setLocationRelativeTo(parent);
    }
    
    public boolean tagsCompatible(int x, int y) {
        return ((x==1 || x==2) && (y==1 || y==2))
                || (x==3 && y==3);
    }

/*
    public int findInRows(GrammarRuleSymbol x) {
        for (int i=1; i<tree.getRowCount(); i++) {
            DefaultMutableTreeNode node = (DefaultMutableTreeNode)tree.getPathForRow(i).getLastPathComponent();
            GrammarRuleSymbol grs = (GrammarRuleSymbol)node.getUserObject();
            if (grs!=x && tagsCompatible(x.tag,grs.tag) && x.symbol.equals(grs.symbol)) return i;
        }
        return -1;
    }*/

    public TreePath findInSubtrees(GrammarRuleSymbol x, TreePath path) {
        TreeNode par = (TreeNode)path.getLastPathComponent();
        for (Enumeration e = par.children(); e.hasMoreElements(); ) {
            DefaultMutableTreeNode node = (DefaultMutableTreeNode)e.nextElement();
            TreePath nodePath =  path.pathByAddingChild(node);
            GrammarRuleSymbol grs = (GrammarRuleSymbol)node.getUserObject();
            if (grs!=x && tagsCompatible(x.tag,grs.tag) && x.symbol.equals(grs.symbol)) return nodePath;
            else {
                TreePath recres = findInSubtrees(x, nodePath);
                if (recres!=null) return recres;
            }
        }
        return null;
    }

    public boolean existsInBranch(String x, DefaultMutableTreeNode par, DefaultMutableTreeNode branchStart) {
        DefaultMutableTreeNode node = par;
        if (branchStart!=null) do {
            GrammarRuleSymbol grs = (GrammarRuleSymbol)node.getUserObject();
            if (grs.symbol.equals(x)) return true;
            node = (DefaultMutableTreeNode)node.getParent();
        } while (node!=null && node!=branchStart);
        return false;
    }

    public void addNodes(DefaultMutableTreeNode par, DefaultMutableTreeNode branchStart, String x, int tag) throws AmosException {
//        if (par.getLevel()>20) return; //DEBUG
        Tuple arg = new Tuple(3);
        arg.setElem(0, ap.grammar);
        arg.setElem(1, x);
        arg.setElem(2, tag);
        Scan scan = ap.conn.callFunction(ap.getGroupedSetFn, arg);
        while (!scan.eos()) {
            Tuple res = scan.getRow();
            GrammarRuleSymbol grs = new GrammarRuleSymbol(res.getSeqElem(0),
                    res.getStringElem(1), tag, (res.getIntElem(2) == 1), list);
            if (!((tag != 1) && existsInBranch(grs.symbol, par, branchStart))) { //add only new symbols to branch when processing BDW or IDE
                DefaultMutableTreeNode yNode = new DefaultMutableTreeNode(grs);
                par.add(yNode);
                if (grs.nt) {
                    //grs.original = findInRows(grs);
                    grs.original = findInSubtrees(grs, tree.getPathForRow(0));
                    if (grs.original == null) { //add recursive nodes only for the first occurence of NT in tree
                        if (tag == 1) {
                            addNodes(yNode, null, grs.symbol, 2); //add all begins-directly-with nodes
                        } else if (tag == 2) {
                            addNodes(yNode, (branchStart == null) ? par : branchStart, grs.symbol, 2); //add recursive begins-directly-with nodes
                        } else if (tag == 3) {
                            addNodes(yNode, null, grs.symbol, 1); //add all is-directly-followed-by nodes
                            addNodes(yNode, (branchStart == null) ? par : branchStart, grs.symbol, 3); //add recursive is-direct-end-of nodes
                            }

                    }
                }
            }
            scan.nextRow();
        }
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jSplitPane1 = new javax.swing.JSplitPane();
        jScrollPane1 = new javax.swing.JScrollPane();
        list = new javax.swing.JList();
        jScrollPane2 = new javax.swing.JScrollPane();
        tree = new javax.swing.JTree();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setName("Form"); // NOI18N

        jSplitPane1.setDividerLocation(150);
        jSplitPane1.setName("jSplitPane1"); // NOI18N

        jScrollPane1.setName("jScrollPane1"); // NOI18N

        list.setModel(listModel);
        list.setName("list"); // NOI18N
        list.addListSelectionListener(new javax.swing.event.ListSelectionListener() {
            public void valueChanged(javax.swing.event.ListSelectionEvent evt) {
                listValueChanged(evt);
            }
        });
        jScrollPane1.setViewportView(list);

        jSplitPane1.setLeftComponent(jScrollPane1);

        jScrollPane2.setName("jScrollPane2"); // NOI18N

        tree.setModel(treeModel);
        tree.setName("tree"); // NOI18N
        tree.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                treeMouseClicked(evt);
            }
        });
        jScrollPane2.setViewportView(tree);

        jSplitPane1.setRightComponent(jScrollPane2);

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addComponent(jSplitPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 677, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addComponent(jSplitPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 542, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void treeMouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_treeMouseClicked
        if (evt.getClickCount()>1) {
            DefaultMutableTreeNode clickedNode = (DefaultMutableTreeNode)tree.getSelectionPath().getLastPathComponent();
            if (clickedNode!=null) {
                GrammarRuleSymbol grs = (GrammarRuleSymbol)clickedNode.getUserObject();
                if (grs.original!=null) {
                    tree.setSelectionPath(grs.original);
                    tree.scrollPathToVisible(grs.original);
                }

            }
        }
    }//GEN-LAST:event_treeMouseClicked

    private void listValueChanged(javax.swing.event.ListSelectionEvent evt) {//GEN-FIRST:event_listValueChanged
        tree.updateUI();
    }//GEN-LAST:event_listValueChanged

    /**
    * @param args the command line arguments
    */
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(new Runnable() {
            public void run() {
                new ListAndTreeForm().setVisible(true);
            }
        });
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JSplitPane jSplitPane1;
    private javax.swing.JList list;
    private javax.swing.JTree tree;
    // End of variables declaration//GEN-END:variables

}
