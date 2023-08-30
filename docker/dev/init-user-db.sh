#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-SQL
  create user postgres with password 'postgres';
  alter user postgres with superuser;
SQL
