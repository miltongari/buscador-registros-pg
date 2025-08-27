import express from 'express';
import pool from '../config/db.js';

/**
 * GET /api/empresas
 * Parámetros:
 *  - q: término de búsqueda (opcional, busca en razón social, municipio, departamento y actividades)
 *  - page: página (1 por defecto)
 *  - limit: tamaño de página (20 por defecto, máx 100)
 */
const router = express.Router();

router.get('/', async (req, res, next) => {
  try {
    const { q = '', page = 1, limit = 20 } = req.query;

    const pageNum = Math.max(parseInt(page) || 1, 1);
    const pageSize = Math.min(Math.max(parseInt(limit) || 20, 1), 100);
    const offset = (pageNum - 1) * pageSize;

    const client = await pool.connect();
    try {
      // Filtro dinámico
      const term = (q || '').trim();
      const where = [];
      const params = [];
      let idx = 1;

      if (term) {
        where.push(`(
            e.razon_social ILIKE '%' || $${idx} || '%' OR
            e.municipio ILIKE '%' || $${idx} || '%' OR
            e.departamento ILIKE '%' || $${idx} || '%' OR
            a.nombre ILIKE '%' || $${idx} || '%'
          )`);
        params.push(term);
        idx += 1;
      }

      const whereSQL = where.length ? "WHERE " + where.join(" AND ") : "";

      // Conteo de empresas distintas que cumplen el filtro
      const countSQL = `
        SELECT COUNT(DISTINCT e.id) AS total
        FROM empresas e
        LEFT JOIN empresa_actividad ea ON ea.empresa_id = e.id
        LEFT JOIN actividades a ON a.id = ea.actividad_id
        ${whereSQL};
      `;
      const countResult = await client.query(countSQL, params);
      const total = Number(countResult.rows[0]?.total || 0);

      // Datos paginados con agregación de actividades
      const dataSQL = `
        SELECT
          e.id,
          e.razon_social,
          e.departamento,
          e.municipio,
          e.direccion_comercial,
          e.fecha_matricula,
          e.rep_legal,
          COALESCE(STRING_AGG(DISTINCT a.nombre, ', '), '') AS actividades
        FROM empresas e
        LEFT JOIN empresa_actividad ea ON ea.empresa_id = e.id
        LEFT JOIN actividades a ON a.id = ea.actividad_id
        ${whereSQL}
        GROUP BY e.id
        ORDER BY e.razon_social ASC
        LIMIT ${pageSize} OFFSET ${offset};
      `;
      const dataResult = await client.query(dataSQL, params);

      res.json({
        ok: true,
        total,
        page: pageNum,
        pageSize,
        rows: dataResult.rows
      });
    } finally {
      client.release();
    }
  } catch (err) {
    err.publicMessage = 'No se pudo completar la búsqueda de empresas';
    return next(err);
  }
});

export default router;
