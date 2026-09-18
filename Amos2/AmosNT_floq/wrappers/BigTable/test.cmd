@echo off

call compile

call mkdmp

echo load_amosql("regress/test.amosql"); | call bigWrapper

