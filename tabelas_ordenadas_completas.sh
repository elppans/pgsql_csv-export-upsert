#!/bin/bash

source banco_psql_export.env

INPUT="tabelas.txt"
OUTPUT="tabelas_ordenadas_completas.txt"

> temp_dependencias.txt
> todas_tabelas.txt
> "$OUTPUT"

# Coleta dependências
while read -r tabela; do
    echo "$tabela" >> todas_tabelas.txt
    psql -qtAX <<EOF >> temp_dependencias.txt
SELECT '$tabela' AS tabela_dependente, confrelid::regclass::text AS tabela_referenciada
FROM pg_constraint
WHERE contype = 'f'
  AND conrelid::regclass::text = '$tabela'
  AND confrelid::regclass::text IN (
      SELECT unnest(string_to_array('$(tr '\n' ',' < $INPUT)', ','))
  );
EOF
done < "$INPUT"

# Ordenação topológica
cat temp_dependencias.txt | awk -F'|' '{print $2, $1}' | tsort > "$OUTPUT"

# Adiciona tabelas que não apareceram na ordenação
grep -vxFf "$OUTPUT" todas_tabelas.txt >> "$OUTPUT"

# Limpeza
rm temp_dependencias.txt todas_tabelas.txt

echo "✅ Lista completa e ordenada salva em $OUTPUT"
