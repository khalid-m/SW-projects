EXTRA_DIST=test_agsl.h

TESTS = vector matrix blas1 blas2 blas3 linalg toupper tolower \
tosymmetric solvemm form

noinst_PROGRAMS = vector matrix blas1 blas2 blas3 linalg	\
tolower toupper tosymmetric solvemm form copy gemm trmm symm	\
lu chol lusolve cholsolve solve

gemm_SOURCES = time_gemm.c
trmm_SOURCES = time_trmm.c
symm_SOURCES = time_symm.c

lu_SOURCES = time_lu.c
chol_SOURCES = time_cholesky.c

solve_SOURCES = time_solve.c
lusolve_SOURCES = time_lu_solve.c
cholsolve_SOURCES = time_cholesky_solve.c

copy_SOURCES = time_copy.c
vector_SOURCES = test_vector.c
matrix_SOURCES = test_matrix.c
tolower_SOURCES = test_matrix_tolower.c
toupper_SOURCES = test_matrix_toupper.c
tosymmetric_SOURCES = test_matrix_tosymmetric.c
solvemm_SOURCES = test_matrix_solve.c

form_SOURCES = test_matrix_form.c

blas1_SOURCES = test_blas1.c
blas2_SOURCES = test_blas2.c
blas3_SOURCES = test_blas3.c
linalg_SOURCES = test_linalg.c

AM_CFLAGS = $(CHECK_CFLAGS) $(AMOS2_CFLAGS) 
AM_LDFLAGS = $(CHECK_LIBS) $(AMOS2_LIBS)	\
 $(top_builddir)/libamosgsl.la

AM_CFLAGS += $(GSL_CFLAGS) 
AM_LDFLAGS += $(BLAS_LIBS) $(FLIBS) -lgsl -lm



