(load "lsp/base.lsp")

;;; Casts a streamfile/1 stream to a Stream of Vectors.
(osql "create function vstreamfile(Charstring file) -> Stream of Vector as cast(streamfile(file) as Stream of Vector);")
