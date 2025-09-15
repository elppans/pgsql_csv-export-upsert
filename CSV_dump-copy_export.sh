#!/bin/bash
# Exportar as tabelas em "tabelas.txt" para arquivo .csv com delimitador ';'
# Uso: CSV_dump-copy_export.sh

# Comando
command="$(basename $0)"

# Diretório do arquivo
file_dir="$(dirname $command)" # "$(dirname "$file")"
mkdir -p "$file_dir/LOGGERAL"

# Caminho do log
log_file="$file_dir/LOGGERAL/$command".log # lnx_conv_log.txt"

# Log geral
LOGFILE="$log_file" # ${0##*/}".log
LOGFILEERROR="$log_file"_error # ${0##*/}"_error.log
exec 1> >(tee -a "$LOGFILE")
exec 2> >(tee -a "$LOGFILEERROR")

# Define variáveis PostgreSQL
source "$file_dir/banco_psql_export.env"

while read tbl; do
    echo "Tentando copiar tabela $tbl ..."
    if psql -c "\copy public.\"$tbl\" TO '${tbl}.csv' CSV DELIMITER '$CSV_DELIMITER' HEADER" >/dev/null 2>>"$LOGFILEERROR" ; then
        echo "  -> OK (salvo em ${tbl}.csv)"
    else
        echo "  -> ERRO (não foi possível exportar $tbl)"
        rm -f "${tbl}.csv"
    fi
done < tabelas.txt
