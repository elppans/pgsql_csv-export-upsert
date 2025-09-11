#!/bin/bash
# Uso: ./CSV_import-upsert-full.sh

###############################################################################
# Funções utilitárias
###############################################################################
sleeping() {
  local segs=$1
  for ((i = segs; i >= 1; i--)); do
    echo -ne "$i Seg.\r"
    sleep 1
  done
  echo
}

log_msg() {
  local msg="$1"
  echo "[$(date +%H:%M:%S)] $msg"
}

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

source "$file_dir/csv_banco.env"

###############################################################################
# Valida conexão
###############################################################################
log_msg "Validando conexão com o banco..."
if ! psql -c "SELECT 1;" >/dev/null 2>&1; then
  log_msg "Falha ao conectar em $PGDATABASE @ $PGHOST"
  exit 1
fi
log_msg "Conexão OK com $PGDATABASE @ $PGHOST"
sleeping 3

###############################################################################
# Coleta arquivos CSV
###############################################################################

if [[ -z "$CSV_DELIMITER" ]]; then
  echo "Delimitador CSV não definido. Configure CSV_DELIMITER no .env"
  exit 1
fi

FILES=( $(find "$DUMP_DIR" -maxdepth 1 -type f -name '*.csv' | sort) )
TOTAL=${#FILES[@]}

if [[ $TOTAL -eq 0 ]]; then
  log_msg "Nenhum CSV encontrado em $DUMP_DIR"
  exit 0
fi

log_msg "Arquivos encontrados:"
printf "→ %s\n" "${FILES[@]}"

###############################################################################
# Loop de importação
###############################################################################
for FILE in "${FILES[@]}"; do
  TABELA=$(basename "$FILE" .csv | sed 's/^dump_//')
  log_msg "Processando tabela: $TABELA"

  # Verifica se a tabela existe
  if ! psql -tAc "SELECT to_regclass('$TABELA')" | grep -q "$TABELA"; then
    log_msg "Tabela '$TABELA' não existe. Pulando..."
    continue
  fi

  # Subshell com log individual por tabela
  (
    table_log="$file_dir/LOGGERAL/$TABELA.log"
    exec > >(tee -a "$table_log")
    exec 2> >(tee -a "$table_log"_error)

    psql <<EOF
CREATE TEMP TABLE tmp_import (LIKE $TABELA INCLUDING ALL);
\copy tmp_import FROM '$FILE' DELIMITER '$CSV_DELIMITER' CSV HEADER;
INSERT INTO $TABELA
SELECT * FROM tmp_import
ON CONFLICT DO NOTHING;
EOF

    if [ $? -eq 0 ]; then
      log_msg ">>> Importação concluída com sucesso para '$TABELA'"
      psql -c "SELECT count(*) AS total_linhas FROM $TABELA;"
    else
      log_msg ">>> ERRO na importação para '$TABELA'"
    fi
  )
done
