import sqlite3
import pandas as pd

# --- Arquivos CSV (ajuste os caminhos se necessário) ---
files = {
    "alunos": "data/alunos.csv",
    "cursos": "data/cursos.csv",
    "inscricoes": "data/inscricoes.csv",
    "modulos": "data/modulos.csv",
    "progresso": "data/progresso.csv",
    "dashboard_kpis": "data/dashboard_kpis.csv",
}


# --- Criar conexão com SQLite ---
conn = sqlite3.connect("medhub.db")

# --- Criar tabelas e importar CSVs ---
for table, path in files.items():
    print(f"Carregando {path} na tabela {table}...")
    df = pd.read_csv(path)
    df.to_sql(table, conn, if_exists="replace", index=False)

print("\nBanco de dados 'medhub.db' criado e populado com sucesso!")

# --- Teste: mostra as 5 primeiras linhas de cada tabela ---
for table in files.keys():
    print(f"\nPrévia da tabela {table}:")
    preview = pd.read_sql(f"SELECT * FROM {table} LIMIT 5", conn)
    print(preview)

# --- Fechar conexão ---
conn.close()
