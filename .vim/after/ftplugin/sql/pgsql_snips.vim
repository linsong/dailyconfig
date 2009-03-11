if !exists('g:loaded_snips') || exists('s:did_pgsql_snips')
     finish
endif
let s:did_pgsql_snips = 1
let snippet_file = 'pgsql'
let snippet_filetype = 'sql' 

exec "Snipp func CREATE or REPLACE FUNCTION ${1} RETURNS ${2} AS
\\n$BODY$
\\nDECLARE
\\n\t${3}
\\nBEGIN
\\n\t${4}
\\nEND;
\\n$BODY$
\\nLANGUAGE plpgsql;"

exec "Snipp for FOR ${1} IN ${2} LOOP
\\n\t${3}
\\nEND LOOP;"

exec "Snipp table CREATE TABLE ${1} (
\\n\t${2}
\\n);"

exec "Snipp index CREATE INDEX ${1} ON ${2}(${3});"

exec "Snipp type CREATE TYPE ${1} AS (${2});"

exec "Snipp log raise notice '${1}', ${2};"


