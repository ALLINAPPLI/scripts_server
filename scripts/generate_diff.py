#!/usr/bin/env python3
"""
generate_diff.py
Compare deux bases MySQL (source/tmp_source vs dest/tmp_dest) et génère :
- diff.sql (INSERT/UPDATE/DELETE)
- rapport.txt
"""

import os
import re
import gzip
import mysql.connector

# -----------------------------
# 1. Configuration depuis l'environnement
# -----------------------------

DB_HOST_SOURCE = os.getenv("DB_HOST_SOURCE", "localhost")
DB_PORT_SOURCE = int(os.getenv("DB_PORT_SOURCE", "3306"))
DB_NAME_SOURCE = os.getenv("DB_NAME_SOURCE")
DB_USER_SOURCE = os.getenv("DB_USER_SOURCE")
DB_PASS_SOURCE = os.getenv("DB_PASS_SOURCE")

DB_HOST_DEST = os.getenv("DB_HOST_DEST", "localhost")
DB_PORT_DEST = int(os.getenv("DB_PORT_DEST", "3306"))
DB_NAME_DEST = os.getenv("DB_NAME_DEST")
DB_USER_DEST = os.getenv("DB_USER_DEST")
DB_PASS_DEST = os.getenv("DB_PASS_DEST")

EXCLUDED_TABLES_RAW = os.getenv("EXCLUDED_TABLES_STR", "")
LARGE_TABLES_RAW = os.getenv("LARGE_TABLES_STR", "")
TABLES_TO_PROCESS_RAW = os.getenv("TABLES_TO_PROCESS_STR", "")
DATE_SEUIL = os.getenv("DATE_SEUIL", "").strip()
INCLUDE_LARGE_TABLES = os.getenv("INCLUDE_LARGE_TABLES", "0").strip()
DATE_COLUMNS_CUSTOM_RAW = os.getenv("DATE_COLUMNS_CUSTOM_STR", "")
DUMP_PROD_PATH = os.getenv("DUMP_PROD_PATH")

EXCLUDED_TABLES = [t.strip() for t in EXCLUDED_TABLES_RAW.replace(",", " ").split() if t.strip()]
LARGE_TABLES = [t.strip() for t in LARGE_TABLES_RAW.replace(",", " ").split() if t.strip()]
TABLES_TO_PROCESS = [t.strip() for t in TABLES_TO_PROCESS_RAW.replace(",", " ").split() if t.strip()]
DATE_COLUMNS_CUSTOM_RAW_LIST = [t.strip() for t in DATE_COLUMNS_CUSTOM_RAW.replace(",", " ").split() if t.strip()]

# Construire un dict : table -> colonne date
DATE_COLUMNS_CUSTOM = {}
for item in DATE_COLUMNS_CUSTOM_RAW_LIST:
    if ":" not in item:
        continue
    table, col = item.split(":", 1)
    DATE_COLUMNS_CUSTOM[table.strip()] = col.strip()

if INCLUDE_LARGE_TABLES == "0":
    LARGE_TABLES_EXCLUDE = LARGE_TABLES
else:
    LARGE_TABLES_EXCLUDE = []

# -----------------------------
# 2. Connexion MySQL
# -----------------------------

def connect_db(host, port, user, password, database):
    return mysql.connector.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        database=database,
        charset="utf8mb4",
        use_unicode=True,
    )

conn_source = connect_db(DB_HOST_SOURCE, DB_PORT_SOURCE, DB_USER_SOURCE, DB_PASS_SOURCE, DB_NAME_SOURCE)
conn_dest = connect_db(DB_HOST_DEST, DB_PORT_DEST, DB_USER_DEST, DB_PASS_DEST, DB_NAME_DEST)

cur_source = conn_source.cursor(dictionary=True)
cur_dest = conn_dest.cursor(dictionary=True)

# -----------------------------
# 3. Utilitaires
# -----------------------------

def escape_identifier(name: str) -> str:
    return "`" + name.replace("`", "``") + "`"

def escape_string(value):
    if value is None:
        return "NULL"
    if isinstance(value, (int, float)):
        return str(value)
    s = str(value).replace("\\", "\\\\").replace("'", "\\'")
    return f"'{s}'"

def is_table_excluded(table_name: str) -> bool:
    for pattern in EXCLUDED_TABLES:
        if pattern.endswith("*"):
            prefix = pattern[:-1]
            if table_name.startswith(prefix):
                return True
        else:
            if table_name == pattern:
                return True
    for pattern in LARGE_TABLES_EXCLUDE:
        if pattern.endswith("*"):
            prefix = pattern[:-1]
            if table_name.startswith(prefix):
                return True
        else:
            if table_name == pattern:
                return True
    return False

def is_table_in_process_list(table_name: str) -> bool:
    if not TABLES_TO_PROCESS:
        return True  # liste vide => on traite toutes les tables (sous réserve des autres filtres)
    return table_name in TABLES_TO_PROCESS

def get_tables(cursor):
    cursor.execute("SHOW TABLES")
    return [row[list(row.keys())[0]] for row in cursor.fetchall()]

def get_columns(cursor, table):
    cursor.execute(f"SHOW COLUMNS FROM {escape_identifier(table)}")
    cols = []
    for row in cursor.fetchall():
        cols.append(row["Field"])
    return cols

def get_primary_key(cursor, table):
    cursor.execute(f"SHOW COLUMNS FROM {escape_identifier(table)}")
    pk = []
    for row in cursor.fetchall():
        if row["Key"] == "PRI":
            pk.append(row["Field"])
    if not pk:
        cols = get_columns(cursor, table)
        if "id" in cols:
            pk = ["id"]
    return pk

def find_date_column(cursor, table):
    # 1. Si une colonne est définie dans DATE_COLUMNS_CUSTOM, on l'utilise
    if table in DATE_COLUMNS_CUSTOM:
        col = DATE_COLUMNS_CUSTOM[table]
        # On vérifie qu'elle existe bien
        cols = get_columns(cursor, table)
        if col in cols:
            return col

    # 2. Sinon, détection automatique
    cursor.execute(f"SHOW COLUMNS FROM {escape_identifier(table)}")
    candidates = []
    for row in cursor.fetchall():
        field = row["Field"]
        col_type = row["Type"].upper()
        if "TIMESTAMP" in col_type or "DATETIME" in col_type:
            name_lower = field.lower()
            if any(k in name_lower for k in ["created", "changed", "modified", "date", "activity_date"]):
                candidates.append(field)
    for prio in ["changed", "modified_at", "modified", "created", "activity_date_time", "date"]:
        for c in candidates:
            if prio in c.lower():
                return c
    return candidates[0] if candidates else None

def fetch_rows(cursor, table, columns, pk, date_column=None, date_seuil=None):
    cols_escaped = [escape_identifier(c) for c in columns]
    cols_str = ", ".join(cols_escaped)
    q = f"SELECT {cols_str} FROM {escape_identifier(table)}"
    params = []
    if date_column and date_seuil:
        q += f" WHERE {escape_identifier(date_column)} >= %s"
        params = [date_seuil]
    cursor.execute(q, params)
    rows = {}
    for row in cursor.fetchall():
        key = tuple(row[p] for p in pk)
        rows[key] = row
    return rows

def generate_insert(table, columns, row):
    cols_escaped = [escape_identifier(c) for c in columns]
    vals = [escape_string(row[c]) for c in columns]
    return (
        f"INSERT INTO {escape_identifier(table)} ({', '.join(cols_escaped)}) "
        f"VALUES ({', '.join(vals)});"
    )

def generate_update(table, columns, pk, row_source, row_dest):
    sets = []
    for c in columns:
        if c in pk:
            continue
        v_source = row_source[c]
        v_dest = row_dest[c]
        if (v_source is None and v_dest is not None) or \
           (v_source is not None and v_dest is None) or \
           (v_source is not None and v_dest is not None and str(v_source) != str(v_dest)):
            sets.append(f"{escape_identifier(c)} = {escape_string(v_source)}")
    if not sets:
        return None
    where_parts = []
    for p in pk:
        where_parts.append(f"{escape_identifier(p)} = {escape_string(row_source[p])}")
    where_str = " AND ".join(where_parts)
    return f"UPDATE {escape_identifier(table)} SET {', '.join(sets)} WHERE {where_str};"

def generate_delete(table, pk, row):
    where_parts = []
    for p in pk:
        where_parts.append(f"{escape_identifier(p)} = {escape_string(row[p])}")
    where_str = " AND ".join(where_parts)
    return f"DELETE FROM {escape_identifier(table)} WHERE {where_str};"

# -----------------------------
# 4. Extraction de l'ordre des tables depuis le dump PROD
# -----------------------------

def extract_table_order_from_dump(dump_path):
    """
    Extrait la liste ordonnée des tables depuis un dump mysqldump.
    Retourne une liste de noms de tables dans l'ordre d'apparition.
    """
    tables = []
    seen = set()

    # Gère .gz ou .sql brut
    if dump_path.endswith(".gz"):
        f = gzip.open(dump_path, "rt", encoding="utf-8", errors="ignore")
    else:
        f = open(dump_path, "r", encoding="utf-8", errors="ignore")

    try:
        # Patterns typiques de mysqldump :
        # DROP TABLE IF EXISTS `table`;
        # CREATE TABLE `table` (...)
        pattern_drop = re.compile(r"DROP\s+TABLE\s+(?:IF\s+EXISTS\s+)?[`']?(\w+)[`']?", re.IGNORECASE)
        pattern_create = re.compile(r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?[`']?(\w+)[`']?", re.IGNORECASE)

        for line in f:
            line = line.strip()
            if not line:
                continue

            # On cherche d'abord un DROP, puis un CREATE
            m = pattern_drop.search(line)
            if not m:
                m = pattern_create.search(line)
            if not m:
                continue

            table = m.group(1)
            if table not in seen:
                tables.append(table)
                seen.add(table)
    finally:
        f.close()

    return tables

# -----------------------------
# 5. Logique principale
# -----------------------------

if not DUMP_PROD_PATH:
    raise RuntimeError("DUMP_PROD_PATH non défini dans l'environnement")

table_order = extract_table_order_from_dump(DUMP_PROD_PATH)

tables_source = set(get_tables(cur_source))
tables_dest = set(get_tables(cur_dest))
common_tables_set = tables_source & tables_dest

# Ordonner les tables communes selon l'ordre du dump PROD
ordered_common_tables = []
seen = set()

for t in table_order:
    if t in common_tables_set and t not in seen:
        ordered_common_tables.append(t)
        seen.add(t)

# Tables restantes (au cas où elles ne seraient pas dans le dump)
for t in sorted(common_tables_set):
    if t not in seen:
        ordered_common_tables.append(t)
        seen.add(t)

common_tables = ordered_common_tables

diff_sql_lines = []
rapport_lines = []

rapport_lines.append("=== Rapport de différentiel SOURCE (PROD) -> DEST (DEV) ===\n")
if DATE_SEUIL:
    rapport_lines.append(f"Filtre date : >= {DATE_SEUIL}\n")
else:
    rapport_lines.append("Filtre date : aucun (toutes les lignes)\n")

if TABLES_TO_PROCESS:
    rapport_lines.append(f"Tables à traiter (liste restreinte) : {', '.join(TABLES_TO_PROCESS)}\n")
else:
    rapport_lines.append("Tables à traiter : toutes (sous réserve des filtres)\n")

rapport_lines.append("\n")

total_insert = 0
total_update = 0
total_delete = 0

for table in common_tables:
    # Filtre par liste de tables à traiter
    if not is_table_in_process_list(table):
        rapport_lines.append(f"[SKIP LISTE] {table}\n")
        continue

    if is_table_excluded(table):
        rapport_lines.append(f"[EXCLU] {table}\n")
        continue

    cols_source = set(get_columns(cur_source, table))
    cols_dest = set(get_columns(cur_dest, table))
    common_cols = sorted(cols_source & cols_dest)

    if not common_cols:
        rapport_lines.append(f"[SKIP] {table} (aucune colonne commune)\n")
        continue

    pk = get_primary_key(cur_source, table)
    if not pk:
        rapport_lines.append(f"[SKIP] {table} (pas de clé primaire détectée)\n")
        continue

    date_column = find_date_column(cur_source, table)
    if date_column and DATE_SEUIL:
        rapport_lines.append(
            f"[TABLE] {table} | PK: {pk} | Colonnes communes: {len(common_cols)} "
            f"| Filtre date sur {date_column} >= {DATE_SEUIL}\n"
        )
    else:
        rapport_lines.append(
            f"[TABLE] {table} | PK: {pk} | Colonnes communes: {len(common_cols)}\n"
        )

    rows_source = fetch_rows(cur_source, table, common_cols, pk, date_column, DATE_SEUIL if date_column else None)
    rows_dest = fetch_rows(cur_dest, table, common_cols, pk)

    keys_source = set(rows_source.keys())
    keys_dest = set(rows_dest.keys())

    keys_insert = keys_source - keys_dest
    keys_update = keys_source & keys_dest
    keys_delete = keys_dest - keys_source

    nb_insert = len(keys_insert)
    nb_update = 0
    nb_delete = len(keys_delete)

    for k in keys_insert:
        row = rows_source[k]
        sql = generate_insert(table, common_cols, row)
        diff_sql_lines.append(sql)

    for k in keys_update:
        row_source = rows_source[k]
        row_dest = rows_dest[k]
        sql = generate_update(table, common_cols, pk, row_source, row_dest)
        if sql:
            diff_sql_lines.append(sql)
            nb_update += 1

    for k in keys_delete:
        row = rows_dest[k]
        sql = generate_delete(table, pk, row)
        diff_sql_lines.append(sql)

    total_insert += nb_insert
    total_update += nb_update
    total_delete += nb_delete

    rapport_lines.append(
        f"  -> INSERT: {nb_insert}, UPDATE: {nb_update}, DELETE: {nb_delete}\n"
    )

rapport_lines.append("\n=== Résumé ===\n")
rapport_lines.append(f"Total INSERT : {total_insert}\n")
rapport_lines.append(f"Total UPDATE : {total_update}\n")
rapport_lines.append(f"Total DELETE : {total_delete}\n")

# -----------------------------
# 6. Écriture des fichiers
# -----------------------------

with open("diff.sql", "w", encoding="utf-8") as f:
    f.write("-- Diff SQL SOURCE (PROD) -> DEST (DEV)\n")
    if DATE_SEUIL:
        f.write(f"-- Filtre date : >= {DATE_SEUIL}\n")
    f.write("\n".join(diff_sql_lines))
    f.write("\n")

with open("rapport.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(rapport_lines))

print("Fichiers générés : diff.sql, rapport.txt")