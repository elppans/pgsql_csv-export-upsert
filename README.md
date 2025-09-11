# pgsql_csv-export-upsert
o arquivo `tabelas.txt` está no repositório [sh-bd](https://github.com/elppans/sh-bd);  
Configure o arquivo `csv_banco.env` para definir o usuário, senha, nome do banco, etc.  
Para extrair as tabelas do banco, crie um arquivo com o nome `tabelas.txt` no mesmo diretório e coloque todas as tabelas de interesse em formato de lista. O arquivo não pode ter quebra de linha com espaço no final. Então, execute o comando:

```bash
./CSV_dump-copy_export.sh
```

Antes de importar as tabelas, faça um teste para ver se dá certo, com o comando:

```bash
./CSV_import-teste.sh  <nome_tabela> <arquivo.csv>
```

Se estiver certo em finalmente upar todos o CSV, faça:

```bash
CSV_import-upsert.sh  <nome_tabela> <arquivo.csv>
```
