#!/bin/bash

# Carrega variáveis de ambiente
source banco_psql_export.env

# Arquivos
INPUT="tabelas.txt"
OUTPUT="tabelas_referenciadas.txt"

# Limpa o arquivo de saída
> "$OUTPUT"

# Loop pelas tabelas
while read -r tabela; do
    dependencias=$(psql -qtAX <<EOF
SELECT confrelid::regclass::text
FROM pg_constraint
WHERE contype = 'f'
  AND conrelid::regclass::text = '$tabela';
EOF
)

    # Formata saída
    if [ -n "$dependencias" ]; then
        deps=$(echo "$dependencias" | paste -sd ", " -)
        echo "$tabela -> $deps" >> "$OUTPUT"
    else
        echo "$tabela -> (sem dependências)" >> "$OUTPUT"
    fi
done < "$INPUT"

echo "✅ Dependências salvas em $OUTPUT"
