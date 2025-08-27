
-- === Esquema normalizado para datos de Huila ===
-- Ejecuta este script en tu base de datos (por ejemplo: psql -U postgres -d buscador_db -f backend/sql/huila_setup.sql)

CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Tablas
DROP TABLE IF EXISTS empresa_actividad;
DROP TABLE IF EXISTS actividades;
DROP TABLE IF EXISTS empresas;

CREATE TABLE empresas (
  id INTEGER PRIMARY KEY, -- usamos el Conse del Excel como ID estable
  org_juridica TEXT,
  categoria TEXT,
  fecha_matricula DATE,
  razon_social TEXT,
  tipo_identificacion TEXT,
  numero_identificacion TEXT,
  desc_tamano_empresa TEXT,
  departamento TEXT,
  municipio TEXT,
  direccion_comercial TEXT,
  NumeroCelular TEXT,
  correo_comercial TEXT,
  rep_legal TEXT
);

CREATE TABLE actividades (
  id INTEGER PRIMARY KEY,
  nombre TEXT NOT NULL UNIQUE
);

CREATE TABLE empresa_actividad (
  empresa_id INTEGER NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  actividad_id INTEGER NOT NULL REFERENCES actividades(id) ON DELETE CASCADE,
  PRIMARY KEY (empresa_id, actividad_id)
);

-- Índices recomendados para búsqueda por texto
CREATE INDEX IF NOT EXISTS idx_empresas_mpio_trgm   ON empresas USING GIN (municipio gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_empresas_mpio       ON empresas(municipio);
CREATE INDEX IF NOT EXISTS idx_actividades_trgm     ON actividades USING GIN (nombre gin_trgm_ops);

-- (Opcional) Índices BTREE para filtros exactos
CREATE INDEX IF NOT EXISTS idx_empresas_dep ON empresas(departamento);
CREATE INDEX IF NOT EXISTS idx_empresas_mpio ON empresas(municipio);

-- Carga desde CSV usando \copy (lado cliente). Ajusta las rutas si es necesario.
-- Si ejecutas desde la carpeta raíz del backend, puedes usar rutas relativas como estas:
-- \copy actividades(id,nombre) FROM 'backend/sql/data/actividades.csv' WITH (FORMAT csv, HEADER true);
-- \copy empresas(id,org_juridica,categoria,fecha_matricula,razon_social,tipo_identificacion,numero_identificacion,desc_tamano_empresa,departamento,municipio,direccion_comercial,NumeroCelular,correo_comercial,rep_legal) FROM 'backend/sql/data/empresas.csv' WITH (FORMAT csv, HEADER true);
-- \copy empresa_actividad(empresa_id,actividad_id) FROM 'backend/sql/data/empresa_actividad.csv' WITH (FORMAT csv, HEADER true);
