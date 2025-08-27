-- Extensiones recomendadas
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ==============================
-- TABLA: categorias
-- ==============================
DROP TABLE IF EXISTS categorias CASCADE;
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    actividad_economica TEXT NOT NULL
);

-- ==============================
-- TABLA: empresas (desde hoja Huila)
-- ==============================
DROP TABLE IF EXISTS empresas CASCADE;
CREATE TABLE empresas (
    id SERIAL PRIMARY KEY,
    conse INT,
    org_juridica TEXT,
    categoria TEXT,
    fecha_matricula DATE,
    razon_social TEXT NOT NULL,
    tipo_identificacion TEXT,
    numero_identificacion BIGINT,
    actividad_economica TEXT,
    actividad_economica2 TEXT,
    actividad_economica3 TEXT,
    actividad_economica4 TEXT,
    desc_tamano_empresa TEXT,
    departamento TEXT,
    municipio TEXT,
    direccion_comercial TEXT,
    numero_celular TEXT,
    correo_comercial TEXT,
    rep_legal TEXT
);

-- ==============================
-- IMPORTAR DATOS DEL EXCEL
-- ==============================
-- Asumiendo que exportaste tus hojas a CSV: categorias.csv y Huila.csv
-- y los copiaste a /docker-entrypoint-initdb.d/ o a una ruta accesible
-- (ajusta la ruta según tu entorno)

-- Cargar categorias
COPY categorias(actividad_economica)
FROM '/docker-entrypoint-initdb.d/categorias.csv'
DELIMITER ',' CSV HEADER;

-- Cargar empresas
COPY empresas(conse, org_juridica, categoria, fecha_matricula, razon_social,
              tipo_identificacion, numero_identificacion, actividad_economica,
              actividad_economica2, actividad_economica3, actividad_economica4,
              desc_tamano_empresa, departamento, municipio, direccion_comercial,
              numero_celular, correo_comercial, rep_legal)
FROM '/docker-entrypoint-initdb.d/Huila.csv'
DELIMITER ',' CSV HEADER;

-- ==============================
-- DATOS DE PRUEBA EXTRA (para búsquedas por frases)
-- ==============================
INSERT INTO empresas (
    conse, org_juridica, categoria, fecha_matricula, razon_social, tipo_identificacion,
    numero_identificacion, actividad_economica, actividad_economica2, desc_tamano_empresa,
    departamento, municipio, direccion_comercial, numero_celular, correo_comercial, rep_legal
) VALUES
(2001, 'Est. Ag. Suc', 'COMERCIO', '2023-05-15',
 'Panadería El Trigal Azul', 'NIT', 900111222,
 'Elaboración de pan y productos de panadería artesanal',
 'Venta al por menor de alimentos y bebidas en Neiva',
 'PEQUEÑA', 'HUILA', 'NEIVA', 'Carrera 7 #12-34 Centro',
 '3101234567', 'contacto@trigalazul.com', 'Juan Pérez'),

(2002, 'Est. Ag. Suc', 'TECNOLOGÍA', '2022-09-20',
 'Tecnología Verde y Rápida', 'NIT', 901222333,
 'Comercio de equipos electrónicos y soluciones verdes',
 'Instalación de paneles solares y energía renovable',
 'MEDIANA', 'HUILA', 'LA PLATA', 'Calle 8 #45-67',
 '3127654321', 'info@verde-rapida.com', 'María Gómez'),

(2003, 'Est. Ag. Suc', 'SALUD', '2023-01-10',
 'Farmacia Salud Total', 'NIT', 902333444,
 'Comercio al por menor de productos farmacéuticos',
 'Servicios médicos y salud preventiva',
 'GRANDE', 'HUILA', 'SUAZA', 'Av. Principal #99',
 '3139876543', 'ventas@saludtotal.com', 'Carlos Ruiz'),

(2004, 'Est. Ag. Suc', 'EVENTOS', '2024-03-12',
 'Eventos Rápidos y Elegantes', 'NIT', 903444555,
 'Catering para eventos y banquetes',
 'Organización de convenciones y ferias comerciales',
 'PEQUEÑA', 'HUILA', 'NEIVA', 'Calle 10 #20-30',
 '3148765432', 'eventos@rapidoelegante.com', 'Lucía Martínez');

-- ==============================
-- ÍNDICES PARA BÚSQUEDA
-- ==============================
CREATE INDEX IF NOT EXISTS idx_empresas_razon_trgm ON empresas USING GIN (razon_social gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_empresas_act1_trgm ON empresas USING GIN (actividad_economica gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_empresas_correo_trgm ON empresas USING GIN (correo_comercial gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_empresas_municipio ON empresas (municipio);
CREATE INDEX IF NOT EXISTS idx_empresas_departamento ON empresas (departamento);
