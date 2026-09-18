#!/bin/sh
# Regenerate every generated reference in Amos2/ from the AmosNT_floq/ source.
# Usage (from anywhere):  sh Amos2/tools/regenerate.sh
# Each file is written to a temporary name first, so a failing generator leaves the old file intact.
set -e
cd "$(dirname "$0")/.."

for pair in \
    gen_lsp_index:LSP_FUNCTION_INDEX \
    gen_c_builtins:C_BUILTINS \
    gen_grammar_map:GRAMMAR_MAP \
    gen_rewrite_rules:REWRITE_RULES \
    gen_amosql_functions:AMOSQL_FUNCTIONS \
    gen_c_api:C_API
do
    script="tools/${pair%%:*}.py"
    out="${pair##*:}.md"
    python3 -B "$script" > "$out.tmp"
    mv "$out.tmp" "$out"
    echo "wrote $out ($(wc -l < "$out" | tr -d ' ') lines)"
done
