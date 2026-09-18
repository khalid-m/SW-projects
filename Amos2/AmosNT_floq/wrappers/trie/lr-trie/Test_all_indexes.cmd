call mkhist.cmd

@echo *
@echo **************************************************************
@echo testing original SCSQ-LR ....................................
@echo **************************************************************
@echo *
copy "src\visited.lsp_versions\visited_original.lsp" src\visited.lsp /y
call mkdmp.cmd
call test.cmd


@echo *
@echo **************************************************************
@echo testing Judy-based SCSQ-LR ..................................
@echo **************************************************************
@echo *
copy "src\visited.lsp_versions\visited - Judy.lsp" src\visited.lsp /y
call mkdmp.cmd
call test.cmd


@echo *
@echo **************************************************************
@echo testing Naive-trie-based SCSQ-LR ............................ 
@echo **************************************************************
@echo *
copy "src\visited.lsp_versions\visited - naive trie.lsp" src\visited.lsp /y
call mkdmp.cmd
call test.cmd


@echo *
@echo **************************************************************
@echo testing unboxed (improved) B-tree-based SCSQ-LR .............
@echo **************************************************************
@echo *
copy "src\visited.lsp_versions\visited_BT.lsp" src\visited.lsp /y
call mkdmp.cmd
call test.cmd


@echo *
@echo **************************************************************
@echo testing B-tree-based SCSQ-LR with incremental deletion ......
@echo **************************************************************
@echo *
copy "src\visited.lsp_versions\visited_BT_Inc_del.lsp" src\visited.lsp /y
call mkdmp.cmd
call test.cmd


@echo *
@echo **************************************************************
@echo testing range-search-free SCSQ-LR ...........................
@echo **************************************************************
@echo *
copy "src\visited.lsp_versions\visited_no_range_search.lsp" src\visited.lsp /y
call mkdmp.cmd
call test.cmd