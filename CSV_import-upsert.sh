#!/bin/bash
# Uso: ./CSV_import-upsert.sh <tabela_destino> <arquivo.csv>

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
source "$file_dir/banco_psql_import.env"

TABELA="$1"
ARQUIVO="$2"

if [ -z "$TABELA" ] || [ -z "$ARQUIVO" ]; then
    echo "Uso: $0 <tabela_destino> <arquivo.csv>"
    exit 1
fi

psql <<EOF
-- Cria tabela temporária com mesma estrutura
CREATE TEMP TABLE tmp_import (LIKE $TABELA INCLUDING ALL);

-- Copia o CSV para a temporária
\copy tmp_import FROM '$ARQUIVO' DELIMITER '$CSV_DELIMITER' CSV HEADER;

-- Move tudo da temporária para a tabela final
INSERT INTO $TABELA
SELECT * FROM tmp_import;
EOF

if [ $? -eq 0 ]; then
    echo ">>> Importação concluída com sucesso!"
    psql -c "SELECT count(*) AS total_linhas FROM $TABELA;"
else
    echo ">>> ERRO na importação para '$TABELA'."
    exit 1
fi
