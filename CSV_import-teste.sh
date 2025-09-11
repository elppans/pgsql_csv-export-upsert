#!/bin/bash
# Uso: ./CSV_import-teste.sh <tabela_base> <arquivo.csv>

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
source "$file_dir/csv_banco.env"

TABELA="$1"
ARQUIVO="$2"

if [ -z "$TABELA" ] || [ -z "$ARQUIVO" ]; then
    echo "Uso: $0 <tabela_base> <arquivo.csv>"
    exit 1
fi



psql <<EOF
-- cria tabela temporária baseada na estrutura da original
CREATE TEMP TABLE tmp_import (LIKE $TABELA INCLUDING ALL);

-- importa o CSV para a tabela temporária
\copy tmp_import FROM '$ARQUIVO' DELIMITER '$CSV_DELIMITER' CSV HEADER;

-- mostra quantas linhas foram importadas
SELECT count(*) AS linhas_importadas FROM tmp_import;

-- remove a tabela temporária
DROP TABLE tmp_import;
EOF
