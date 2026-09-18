@echo off
echo ---------------------------- Installing --------------
call install

pushd %AMOS_HOME%\wrappers\ROOTWrap
call regress
popd

echo ------------------------ ALEH regression test -------------------------
echo  
echo -------------- Materialized ontology, loading entire file ---
call regress.load

echo -------------- Streaming without ontology -----------------------
call regress.basic

echo ------------ Materialized ontology with aggregate cost model, loading entire file ---
call regress.load.cost.populated

echo ------------ Materialized ontology with simple cost model from paper ---------
call regress.load.cost_model.limited

echo ------------ Materialized ontology with static cost model from paper ---------
call regress.load.cost_model.static

echo ------------ Materialized ontology with dynamic group cost model from paper ---------
call regress.load.cost_model.dynamic

echo ------------ Materialized ontology with profiled grouping cost model from paper --------
echo ------------------- automatic group generation -----------------------------------
call regress.load.cost_model.dyngroups

echo ----------------- Streaming ontology with structs ---------------
echo ------------- with static cost model from paper ----------------
call regress.stream.static_cm.cmd
echo -------------------- Streaming ontology with structs --------------
echo ------------with profiled grouping cost model from paper ---------
call regress.stream.dyngroups.cmd
echo -------------------- Streaming ontology with structs, closed disjunction --------------
echo ------------with static and profiled grouping cost model from paper ---------
call regress.stream.closed.cmd
echo -------------------- Streaming ontology with structs, closed disjunction --------------
echo ------------with no cost model (MAN) ---------
call regress.stream.closed.limited.cmd
echo -------------------- Streaming ontology with structs, closed disjunction --------------
echo ------------with dynamic profiling ---------
call regress.stream.profiling.cmd
echo --------------------------------- Cuts 2005 ------------------------------------
echo -------------------- Streaming ontology with structs, closed disjunction --------------
echo ------------with static and profiled grouping cost model from paper ---------
call regress.stream.profiling.cmd
echo --------------------------------- Cuts 2005 ------------------------------------
echo -------------------- Streaming ontology with structs, closed disjunction --------------
echo ------------with no cost model ---------
call regress.2005.stream.limited.cmd

goto end

:failed
echo ****************************************
echo * Test master is failed
echo * Press any key
echo ****************************************
pause
goto end

:end
