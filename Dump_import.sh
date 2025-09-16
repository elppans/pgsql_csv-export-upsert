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

###############################################################################
# Verificação de argumento
###############################################################################
if [ $# -ne 1 ]; then
    echo "Erro: você deve especificar exatamente um arquivo .dmp.gz como argumento."
    echo "Uso: ./$command arquivo.dmp.gz"
    exit 1
fi

file="$1"

if [[ ! "$file" =~ \.dmp\.gz$ ]]; then
    echo "Erro: o arquivo especificado não possui a extensão .dmp.gz."
    exit 1
fi

if [ ! -f "$file" ]; then
    echo "Erro: o arquivo '$file' não existe."
    exit 1
fi

###############################################################################
# Importação
###############################################################################
gunzip -c "$file" | psql -d "$PGDATABASE"

# Remove o log de erro se estiver vazio
if [ ! -s "$LOGFILEERROR" ]; then
    rm -f "$LOGFILEERROR"
fi
