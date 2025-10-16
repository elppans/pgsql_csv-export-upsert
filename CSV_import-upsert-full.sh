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

source "$file_dir/banco_psql_import.env"

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

FILES=( $(find "$file_dir/CSVDIR" -maxdepth 1 -type f -name '*.csv' | sort) )
TOTAL=${#FILES[@]}

if [[ $TOTAL -eq 0 ]]; then
  log_msg "Nenhum CSV encontrado em $file_dir"
  exit 0
fi

log_msg "Arquivos encontrados:"
printf "→ %s\n" "${FILES[@]}"

declare -A STATUS

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
-- Desabilitar constraints temporariamente
ALTER TABLE $TABELA DISABLE TRIGGER ALL;

-- Cria tabela temporária com mesma estrutura
CREATE TEMP TABLE tmp_import (LIKE $TABELA INCLUDING ALL);

-- Copia o CSV para a temporária
\copy tmp_import FROM '$FILE' DELIMITER '$CSV_DELIMITER' CSV HEADER;

-- Move tudo da temporária para a tabela final
INSERT INTO $TABELA
SELECT * FROM tmp_import;

-- Habilitar constraints novamente
ALTER TABLE $TABELA ENABLE TRIGGER ALL;
EOF

    if [ $? -eq 0 ]; then
      log_msg ">>> Importação concluída com sucesso para '$TABELA'" 
      echo "$TABELA:OK" >> "$file_dir/LOGGERAL/status.tmp"
      psql -c "SELECT count(*) AS total_linhas FROM $TABELA;"
    else
      log_msg ">>> ERRO na importação para '$TABELA'"
      echo "$TABELA:ERRO" >> "$file_dir/LOGGERAL/status.tmp"
    fi

    # Remover log de erro se estiver vazio
    if [ ! -s "$table_log"_error ]; then
      rm -f "$table_log"_error
    fi
  )



done
echo -e "\n📋 Relatório final de importação:"
if [[ -f "$file_dir/LOGGERAL/status.tmp" ]]; then
  while IFS=: read -r tabela status; do
    if [[ "$status" == "OK" ]]; then
      echo "✔️ $tabela: Importação bem-sucedida"
    else
      echo "❌ $tabela: Falhou na importação"
    fi
  done < "$file_dir/LOGGERAL/status.tmp"
  rm -f "$file_dir/LOGGERAL/status.tmp"
else
  echo "Nenhuma tabela foi processada."
fi

# Remove o log de erro se estiver vazio
if [ ! -s "$LOGFILEERROR" ]; then
  rm -f "$LOGFILEERROR"
fi
