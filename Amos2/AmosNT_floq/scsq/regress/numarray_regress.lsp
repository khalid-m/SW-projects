
(checkequal
 "basic numarray construction"
 ((na2vec (caar (osql "iarray({1, 2, 3});")))
  (vector 1 2 3))
 ((na2vec (caar (osql "darray({1.0, 2.0, 3.0});")))
  (vector 1.0 2.0 3.0))
 ((na2vec (caar (osql "carray({1.0, 2.0, 3.0}, {1.0, 2.0, 3.0});")))
  (vector (make-complex 1.0 1.0) (make-complex 2.0 2.0) (make-complex 3.0 3.0)))
 ((errcond-msg (catch-error (osql "carray({1.0, 2.0, 3.0}, {1.0, 2.0});")))
  "Real-imaginary dimensionality mismatch")
 )

(osql "
set :ia = iarray({1, 2, 5});
set :da = darray({2, 8, 6});
")

(checkequal
 "numarray indexing"
 ((osql ":ia[1];") '((2)))
 ((osql ":da[2];") '((6.0)))
 ((osql ":ia[3];") nil)
 ((osql ":da[3];") nil)
 ((osql ":ia[-1];") nil)
 )

(checkequal
 "complex numarray operations"
 ((na2vec (caar (osql "abs(carray({0.0, 3.0, 6.0}, {1.0, 4.0, 8.0}));")))
  (vector 1.0 5.0 10.0))
 ((na2vec (caar (osql "re(carray({0.0, 3.0, 6.0}, {1.0, 4.0, 8.0}));")))
  (vector 0.0 3.0 6.0))
 ((na2vec (caar (osql "im(carray({0.0, 3.0, 6.0}, {1.0, 4.0, 8.0}));")))
  (vector 1.0 4.0 8.0))
 )

(checkequal
 "numarray interleave function"
 ((na2vec (caar (osql "il(iarray({1, 2, 3, 4, 5, 6, 7}), 0, 2);")))
  (vector 1 3 5 7))
 ((na2vec (caar (osql "il(darray({1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0}), 1, 2);")))
  (vector 2.0 4.0 6.0))
 ((na2vec (caar (osql "il(iarray({1, 2, 3, 4, 5, 6, 7}), 0, 3);")))
  (vector 1 4 7))
 ((na2vec (caar (osql "il(carray({1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0},
{1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0}), 1, 3);")))
  (vector (make-complex 2.0 2.0) (make-complex 5.0 5.0)))
 ((na2vec (caar (osql "il(iarray({1, 2, 3, 4, 5, 6, 7}), 7, 2);")))
  (vector)) ; Illegal offset should return empty numarray
 ((na2vec (caar (osql "il(iarray({1, 2, 3, 4, 5, 6, 7}), -1, 2);")))
  (vector))
 ((na2vec (caar (osql "il(iarray({1, 2, 3, 4, 5, 6, 7}), 7, 0);")))
  (vector)) ; Illegal multiple should return empty numarray
 )
