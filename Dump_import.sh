#!/bin/bash
# Uso: ./Dump_import.sh arquivo.dmp.gz

###############################################################################
# Inicialização
###############################################################################
command="$(basename "$0")"
file_dir="$(dirname "$(realpath "$0")")"
mkdir -p "$file_dir/LOGGERAL"

log_file="$file_dir/LOGGERAL/$command.log"
LOGFILE="$log_file"
LOGFILEERROR="$log_file"_error
exec 1> >(tee -a "$LOGFILE")
exec 2> >(tee -a "$LOGFILEERROR")

source "$file_dir/banco_psql_import.env"

file="$@"

gunzip -c "$file" | psql -d "$PGDATABASE"
