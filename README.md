## 📦 pgsql_csv-export-upsert

Scripts para exportar e importar dados em formato CSV no PostgreSQL com suporte a *upsert* e estrutura modular.
>A melhor maneira de se usar a importação é em um banco restaurado com a estrutura dele mesmo.  
>Ver um destes métodos: [Plain Text ou Comprimido](https://elppans.github.io/doc-bd/pg_dump#diferen%C3%A7a-entre-2-comandos-pg_dump)  
>Se for usar este método, é recomendável que adicione a tabela `tab_controle_versao` na primeira linha.
>
>>Leitura recomendada: [Export/Import Dump/CSV](https://elppans.github.io/doc-bd/Dump_de_Banco_export_e_import_de_Tabelas_em_CSV)
---

### 📁 Pré-requisitos

- PostgreSQL instalado e acessível via terminal (`psql`)
- Estar logado diretamente com o usuário `postgres` (**RECOMENDAVEL**)
- Arquivo `banco_psql_export.env`  e `banco_psql_import.env` configurado com as variáveis de conexão:
>Um é para apontar o banco que vai ser exportado e o outro para o banco que vai ser importado

  ```bash
  PGUSER="usuario"
  PGPASSWORD="senha"
  PGHOST="127.0.0.1"
  PGDATABASE="nome_do_banco"
  PGPORT="5432"
  CSV_DELIMITER=";"  # ou outro delimitador usado nos seus CSVs
  ```


- Arquivo `tabelas.txt` contendo os nomes das tabelas a serem exportadas (uma por linha, sem espaços extras).  
  Exemplo disponível no repositório [sh-bd](https://github.com/elppans/sh-bd) (privado)

- Lista de TABELAS  
>Acesso privado, somente quem é aprovado poderá ver as tabelas  

Lista de Tabelas padrão: [tabelas.txt](https://github.com/elppans/sh-bd/blob/main/tabelas.txt)  
Lista de tabelas 2 (Lista para completar o padrão): [tabelas_2.txt](https://github.com/elppans/sh-bd/blob/main/tabelas_2.txt)  
Lista de Tabelas Usuários: [tabelas_usuarios.txt](https://github.com/elppans/sh-bd/blob/main/tabelas_usuarios.txt)  
>As 5 primeiras linhas são os principais e não podem ser removido da lista.  
Lista de Tabelas Mercadorias: [tabelas_mercadorias.txt](https://github.com/elppans/sh-bd/blob/main/tabelas_mercadorias.txt)  
Lista de Tabelas Retiradas (Tabelas desnecessárias): [tabelas_retiradas.txt](https://github.com/elppans/sh-bd/blob/main/tabelas_retiradas.txt)  
Todas as tabelas do banco: [tabelas_full.txt](https://github.com/elppans/sh-bd/blob/main/tabelas_full.txt)  
Todas as tabelas do banco (Configurações, sem movimento, "**RECOMENDADO**"): [tabelas_full_nozan.txt](https://github.com/elppans/sh-bd/blob/main/tabelas_full_nozan.txt)  

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
