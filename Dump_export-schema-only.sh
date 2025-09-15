#!/bin/bash
# Exportar as tabelas em "tabelas.txt" para arquivo .csv com delimitador ';'
# Uso: Dump_export-schema-only.sh

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

pg_dump --verbose --schema-only --no-owner --no-acl --inserts -d "$PGDATABASE" | gzip > "$HOME/"$PGDATABASE"-schema-only_"$(date +%d%m%y%H%M)".dmp.gz"
