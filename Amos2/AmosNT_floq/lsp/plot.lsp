;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2001 Timour Katchaounov, UDBL
;;;
;;; Description: Interface to GNUPlot.
;;; - Best used in conjunction with the profiler to produce graphs 
;;;   of various kind.
;;; - In order to use this module, one of the two must be done:
;;;   - either supply the location of gnuplot.exe to the plot() function
;;;   - set your path to include the location of gnuplot.exe
;;; =============================================================
;;; $Log: plot.lsp,v $
;;; Revision 1.6  2012/05/18 14:34:46  torer
;;; result -> return
;;;
;;; Revision 1.5  2009/09/07 14:12:30  zeitler
;;; count is replaced by dim
;;;
;;; Revision 1.4  2009/08/18 18:14:32  torer
;;; gnuplot package now up-to-date
;;;
;;; =============================================================

(defun print--- (fno string file mode)
  (let ((stream (if file (openstream file mode))))
    (formatl stream string)
    (closestream stream)))

(osql "
create function print(charstring str, charstring file, charstring mode) 
                     -> boolean b
  as foreign 'print---';
")

(defun println--- (fno string file mode)
  (let ((stream (if file (openstream file mode))))
    (formatl stream string t)
    (closestream stream)))

(osql "
create function println(charstring str, charstring file, charstring mode) 
                        -> boolean b
  as foreign 'println---';
")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gnuplot graph settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(osql "
create function tmp_file(charstring fname, charstring ext) -> charstring
  as select fname + '-gplot.' + ext;

create type plot_settings properties(
  name charstring,
  xrange_min number, xrange_max number,
  yrange_min number, yrange_max number,
  xtics number,
  xlabel charstring, ylabel charstring,
  yscale charstring
);

create function plot_header(plot_settings ps) -> charstring
  as foreign 'gen-plot-header-+';
")

(defun gen-plot-header-+ (fno plt-obj)
  "Generate the plot header of a Gnuplot command file"
  (let* ((xr_min1 (get-func 'xrange_min plt-obj))
	 (xr_min (if xr_min1 xr_min1 "*"))
	 (xr_max1 (get-func 'xrange_max plt-obj))
	 (xr_max (if xr_max1 xr_max1 "*"))
	 (yr_min1 (get-func 'yrange_min plt-obj))
	 (yr_min (if yr_min1 yr_min1 "*"))
	 (yr_max1 (get-func 'yrange_max plt-obj))
	 (yr_max (if yr_max1 yr_max1 "*"))
	 (xt     (get-func 'xtics plt-obj))
	 (xl     (get-func 'xlabel plt-obj))
	 (yl     (get-func 'ylabel plt-obj))
	 (ysc    (get-func 'yscale plt-obj))
	 res)
    (if (equal ysc "log")
	(setq ysc "set logscale y 10\;")
        (setq ysc "set nologscale y\;"))
    (setq res
	  (concat
	   "reset\; set term postscript eps\; set data style linespoints\;"
           " set key left top Left\; "
	   "set xrange [" xr_min ":" xr_max "]\; "
	   "set yrange [" yr_min ":" yr_max "]\; "
	   "set xtics " xt "\; "
	   "set xlabel '" xl "' 0\; "
	   "set ylabel '" yl "' 0\; "
	   ysc))
    (osql-result plt-obj res)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2D curves
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(osql "
create type curve2d properties (title charstring);

create function curve2d(charstring t) -> curve2d
  as begin
      declare curve2d c2d;
      create curve2d(title) instances c2d(t);
      return c2d;
     end;

create function points(curve2d c) -> bag of vector as stored;

create function point_lt(vector v1, vector v2) -> boolean
   as select v1[0] < v2[0];")

(osql "
create function get_curve(curve2d c) -> vector v
  as sortbag(points(c), #'point_lt');

create function sum_points(bag of vector point_bag) -> bag of vector
/* Sum the y-coordinate of all points in point_bag that 
   have the same x-coordinate.
   'point_bag' normally contains the points from more than one curve 
   in the same graph.
*/
  as select vector(distinct_x, y_sum)
     from number distinct_x, real y_sum
     where distinct_x in (select distinct point[0]
                          from vector point
                          where point in point_bag)
           and
           y_sum = sum(select y
                       from vector point, real y
                       where y = point[1] and
                             point[0] = distinct_x and
                             point in point_bag);

create function print(curve2d c, charstring file) -> boolean
   as begin
      declare vector curve, integer size, vector point, charstring line,
              number x, number y;
      set curve = get_curve(c);
      set size = dim(curve) - 1;
      println('# ' + title(c), file, 'w');
      for each integer i where i = iota(0,size)
        begin
          set point = curve[i];
          set x = point[0];
          set y = point[1];
          set line = itoa(x) + ' ' + itoa(y);
          println(line, file, 'a');
        end;
      end;
")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2D Graphs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun run-gnuplot- (fno plot-file)
  (system (concat "start wgnuplot.exe " plot-file)))

(osql "
create function run_gnuplot(charstring plot_file) -> boolean
  as foreign 'run-gnuplot-';

create type graph2d properties (
  title charstring,
  output charstring,
  settings plot_settings
);

create function curves(graph2d gr) -> bag of curve2d as stored;

create function graph2d(charstring t, charstring o, plot_settings ps) 
                       -> graph2d
  as begin
     declare graph2d gr;
     create graph2d(title, output, settings)
            instances gr(t, o, ps);
     return gr;
     end;

create function normalize_curve(curve2d crv, graph2D grph) -> bag of vector
  as select vector(x, (y / min_y))
     from vector point, number min_y, number x, number y
     where point = points(crv) and
           x = point[0] and
           y = point[1] and
           min_y = minagg(select y1
                          from number y1, curve2d c, vector pt
                          where c = curves(grph) and
                                pt = points(c) and
                                pt[0] = x and
                                y1 = pt[1]);         

create function normalize_graph(graph2D grph) -> curve2D
  as begin
     declare curve2d new_crv;

     for each curve2d crv where crv = curves(grph)
       begin
       set new_crv = curve2d(title(crv));
       add points(new_crv) = normalize_curve(crv, grph);
       return new_crv;
       end;
     end;

create function plot(graph2d gr, charstring dir) -> charstring
  as begin
     declare charstring plt_file, charstring ps_file, charstring dat_file,
             charstring old_dir, integer curve_num;

     set old_dir = pwd();
     cd(dir);
     set plt_file = tmp_file(output(gr), 'plt');
     set ps_file = tmp_file(output(gr), 'ps');
     set curve_num = 0;

     println(plot_header(settings(gr)), plt_file, 'w');
     println('set title \"' + title(gr) + '\"; set output \"' + ps_file + 
             '\"', plt_file, 'a');
     print('plot ', plt_file, 'a');
     for each curve2d crv where crv = curves(gr)
       begin
       set curve_num = curve_num + 1;
       set dat_file = tmp_file(output(gr) + '-' + itoa(curve_num), 'dat');
       print(crv, dat_file);
       if (curve_num = 1) then 
         begin
         print('\"' + dat_file + '\" using 1:2 title \"' + title(crv) + '\"', 
               plt_file, 'a');
         end else
         begin
         print(', \"' + dat_file + '\" using 1:2 title \"' + title(crv) + 
               '\"', plt_file, 'a');
         end;
       end;
     run_gnuplot(plt_file);
     cd(old_dir);
     end;
")

(defun shutdown-plot ()
  (osql "
delete type plot_settings;
delete type curve2d;
delete type graph2d;
")
  )

*EOF*

/******************************************************************************
 * Test data
 *****************************************************************************/
create plot_settings(name, xrange_min, xrange_max, xtics, xlabel, ylabel)
       instances :ps1('test1', 1, 5, 1, 'servers', 'time');

set :crv1 = curve2d('crv1');
add points(:crv1) = {4,5};
add points(:crv1) = {1,6};
add points(:crv1) = {7,8};
add points(:crv1) = {2,3};

set :crv2 = curve2d('crv2');
add points(:crv2) = {4,7};
add points(:crv2) = {1,8};
add points(:crv2) = {7,10};
add points(:crv2) = {2,5};

set :crv3 = curve2d('crv3');
add points(:crv3) = {4,9};
add points(:crv3) = {1,10};
add points(:crv3) = {7,12};
add points(:crv3) = {2,7};

set :grph1 = graph2d("test", "out.out", :ps1);
add curves(:grph1) = :crv1;
add curves(:grph1) = :crv2;
add curves(:grph1) = :crv3;

plot(:grph1,".");
