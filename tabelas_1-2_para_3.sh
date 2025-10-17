#!/bin/bash

# Este script compara os arquivos 'tabela1.txt' e 'tabela2.txt',
# identifica as palavras únicas de cada um (removendo as que aparecem em ambos),
# e salva o resultado no arquivo 'tabela3.txt'.
# Útil para eliminar duplicatas entre dois conjuntos de dados textuais.

# Remove duplicatas e ordena
tr ' ' '\n' < tabela1.txt | sort -u > temp1.txt
tr ' ' '\n' < tabela2.txt | sort -u > temp2.txt

# Compara e remove palavras comuns
comm -3 temp1.txt temp2.txt | sed 's/^\t//' > tabela3.txt

# Limpa arquivos temporários
rm temp1.txt temp2.txt

