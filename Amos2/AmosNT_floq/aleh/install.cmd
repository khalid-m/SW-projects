@echo off
pushd %AMOS_HOME%\wrappers\ROOTWrap
del ROOTWrap.exe
del ROOTWrap.dmp
del amain.obj
call compile
IF NOT EXIST ROOTWrap.exe GOTO rootwrap_failed
call mkdmp
IF NOT EXIST rootwrap.dmp GOTO rootwrap_dmp_failed
popd

echo ------------------------------ ALEH -------------------------
del aleh.exe
del aleh_load.dmp
del root.dmp
del amain.obj
del TTreeClass.obj

call compile
IF NOT EXIST aleh.exe GOTO aleh_failed

del aleh_load.dmp
del aleh_basic.dmp
del aleh_load.cost.populated.dmp
del aleh_load.cost_model.limited.dmp
del aleh_load.cost_model.static.dmp
del aleh_load.cost_model.dynamic.dmp
del aleh_load.cost_model.dyngroups.dmp
del aleh_stream.static_cm.dmp
del aleh_stream.dyngroups.dmp
del aleh_stream.closed.dmp
del aleh_stream.profiling.dmp
del aleh_stream.limited.dmp
echo -------------- Materialized ontology, loading entire file ---
call mkdmp.load
IF NOT EXIST aleh_load.dmp GOTO load_dmp_failed
echo -------------- Streaming without ontology -----------------------
call mkdmp.basic
IF NOT EXIST aleh_basic.dmp GOTO basic_dmp_failed
echo ------------ Materialized ontology with aggregate cost model, loading entire file ---
call mkdmp.load.cost.populated
IF NOT EXIST aleh_load.cost.populated.dmp GOTO load_dmp_failed
echo ------------ Materialized ontology with simple cost model from paper ---------
call mkdmp.load.cost_model.limited
IF NOT EXIST aleh_load.cost_model.limited.dmp GOTO load_dmp_failed
echo ------------ Materialized ontology with static cost model from paper ---------
call mkdmp.load.cost_model.static
IF NOT EXIST aleh_load.cost_model.static.dmp GOTO load_dmp_failed
echo ------------ Materialized ontology with dynamic group cost model from paper ---------
call mkdmp.load.cost_model.dynamic
IF NOT EXIST aleh_load.cost_model.dynamic.dmp GOTO load_dmp_failed
echo ------------ Materialized ontology with profiled group cost model from paper ---------
echo ------------------ automatic group generation ----------------------
call mkdmp.load.cost_model.dyngroups
IF NOT EXIST aleh_load.cost_model.dyngroups.dmp GOTO load_dmp_failed
echo ------------ Streaming ontology with structs ---------
echo ------------------ static cost model ----------------------
call mkdmp.stream.static_cm.cmd
IF NOT EXIST aleh_stream.static_cm.dmp GOTO stream_dmp_failed
echo ------------ Streaming ontology with structs ---------
echo ------------------ profiled grouping ----------------------
call mkdmp.stream.dyngroups.cmd
IF NOT EXIST aleh_stream.dyngroups.dmp GOTO stream_dmp_failed
echo ------------ Streaming ontology with structs ---------
echo ------------------ Closed disjunction ----------------------
call mkdmp.stream.closed.dyngroups.cmd
IF NOT EXIST aleh_stream.closed.dmp GOTO stream_dmp_failed
echo ------------ Streaming ontology with structs ---------
echo ------------------ Closed disjunction, auto-profiling ----------------------
call mkdmp.stream.profiling.cmd
IF NOT EXIST aleh_stream.profiling.dmp GOTO stream_dmp_failed
echo ------------ Streaming ontology with structs ---------
echo ------------------ Closed disjunction, no hints ----------------------
call mkdmp.stream.closed.limited.cmd
IF NOT EXIST aleh_stream.limited.dmp GOTO stream_dmp_failed
echo ------------ Streaming ontology with structs ---------
echo ------------------ Closed disjunction, dynamic profiling ----------------------
call mkdmp.stream.profiling.cmd
IF NOT EXIST aleh_stream.profiling.dmp GOTO stream_dmp_failed

goto end



:rootwrap_failed
popd
echo *****************************************************************************
echo * Compiling ROOT wrapper is failed
echo 
goto failed

:rootwrap_dmp_failed
popd
echo *****************************************************************************
echo * Creating image for ROOT wrapper is failed
echo 
goto failed

:aleh_failed
echo ****************************************
echo * Compilation of ALEH is failed
echo 
goto failed

:load_dmp_failed
echo *****************************************************************************
echo * Creating image file for materialized ontology loading entire file is failed
echo 
goto failed

:stream_dmp_failed
echo *****************************************************************************
echo * Creating an image file for streaming ontology with structs is failed
echo 
goto failed

:basic_dmp_failed
echo *****************************************************************************
echo * Creating image file for streaming without ontology is failed
echo 
goto failed

:failed
echo ****************************************
echo * Test master is failed
echo * Press any key
echo ****************************************
pause
goto end

:end
