#!/bin/sh
# Installation script/README file for scsq on the LOFAR BG system
# 

# Make directories on the filesystem readable by the BlueGene
# amos dir contains scsq executable, amos2.dmp and init.osql
mkdir /bgl/$HOME/amos

# amos/out dir: output data from the BlueGene executable
mkdir /bgl/$HOME/amos/out

# Build amos2 and make amos2.dmp image
cd $HOME/AmosNT/system/Linux
make

# Build libamos.a using mpicc compiler. The libamos.a is 
# necessary when linking the scsq BG driver program
make -f Makefile.bluegene

# Copy image to BG filesystem
cp ../../bin/amos2.dmp /bgl/$HOME/amos

# Manually edit the following files.
# front.osql:
# (defun gethostname () "10.20.1.17")
# bgsubmit.c
# char *cmd = "submitjob R001_B08 /bgl/home/zeitler/amos/scsq /bgl/home/zeitler/amos/out ../init.osql";

# Make scsq and front node applications
cd ../../astro
make front
make scsq

# Copy init osql code 
cp init.osql /bgl/$HOME/amos

# Before starting, allocate and boot your BG partition
# Find out your block name
availableblocks
# Returns something like
#    R001_B08          8 x   4 x   1 =   32  32   000 C
# Allocate your block (change R001_B08 into what you have)
allocate R001_B08

# Now you are all set!

# Start scsq by running ./front ../bin/amos2.dmp front.osql
# Exercise 1: merge(iota(1,100),iota(1,100));
#             This merges two (iota) streams on the front node
#             using unix pipes
# Exercise 2: bg("pair(merge(iota(1,100),iota(1,100)));");
#             This merges two (iota) streams on the BG using MPI
#             and returns the result to the front node
# NB: Due to a bug in the query compiler, functions returning more than
# one type cannot be submitted to BG. If that is desired, the types must
# be collected into a collection, like the pair function. 
#     pair(object x, object y) -> vector 
# is defined in front.osql (read by front) and init.osql (read by BG)

# If a job seems to hang, look at
# (i) the output, in /bgl/$HOME/amos/out
# (ii) the job queue, by issuing
#      listjobs
# -- and (optionally) killjob partitionID jobID

# At the end of the experiments, free the BG partition using 
freeblock R001_B08
