## 📦 pgsql_csv-export-upsert

Scripts para exportar e importar dados em formato CSV no PostgreSQL com suporte a *upsert* e estrutura modular.
>A melhor maneira de se usar a importação é em um banco restaurado com a estrutura dele mesmo.  
>Ver um destes métodos: [Plain Text ou Comprimido](https://elppans.github.io/doc-bd/pg_dump#diferen%C3%A7a-entre-2-comandos-pg_dump)  
>Se for usar este método, é recomendável que adicione a tabela `tab_controle_versao` na primeira linha.  
---

### 📁 Pré-requisitos

- PostgreSQL instalado e acessível via terminal (`psql`)
- Arquivo `csv_banco.env` configurado com as variáveis de conexão:
  ```bash
  PGUSER="usuario"
  PGPASSWORD="senha"
  PGHOST="127.0.0.1"
  PGDATABASE="nome_do_banco"
  PGPORT="5432"
  CSV_DELIMITER=";"  # ou outro delimitador usado nos seus CSVs
  ```

- Arquivo `tabelas.txt` contendo os nomes das tabelas a serem exportadas (uma por linha, sem espaços extras).  
  Exemplo disponível no repositório [sh-bd](https://github.com/elppans/sh-bd)

---

### 📤 Exportar tabelas para CSV

Para extrair os dados das tabelas listadas em `tabelas.txt`:

```bash
./CSV_dump-copy_export.sh
```

---

### 🧪 Testar importação de um CSV

Antes de fazer o *upsert*, teste a importação de um arquivo específico:

```bash
./CSV_import-teste.sh <nome_tabela> <arquivo.csv>
```

---

### ⬆️ Importar com upsert (um arquivo)

Se estiver tudo certo, faça o *upsert* para uma tabela específica:

```bash
./CSV_import-upsert.sh <nome_tabela> <arquivo.csv>
```

---

### 🔁 Importar todos os CSVs do diretório

Para importar todos os arquivos `.csv` presentes no diretório definido em `DUMP_DIR`:

```bash
./CSV_import-upsert-full.sh
```

---
