/**
 * Ruta de búsqueda principal: GET /api/search
 *
 * Parámetros de query:
 *  - q: término de búsqueda (opcional)
 *  - page: número de página (1 por defecto)
 *  - limit: tamaño de página (20 por defecto, máx 100)
 *
 * Respuesta:
 *  { ok: true, total, page, pageSize, rows: [...] }
 *
 * Implementa búsqueda básica con ILIKE en columnas "title" y "description".
 * Incluye conteo total y paginación.
 */
import express from 'express';
import pool from '../config/db.js';

const router = express.Router();

// Sanitiza y normaliza parámetros
function parseIntOr(value, fallback) {
  const n = parseInt(value, 10);
  return Number.isFinite(n) ? n : fallback;
}

router.get('/search', async (req, res, next) => {
  const q = (req.query.q || '').toString().trim();
  const page = Math.max(1, parseIntOr(req.query.page, 1));
  const limitRaw = Math.max(1, parseIntOr(req.query.limit, 20));
  const limit = Math.min(100, limitRaw); // evita páginas enormes
  const offset = (page - 1) * limit;

  // Construimos WHERE de forma segura usando parámetros
  const whereParts = [];
  const params = [];

  if (q) {
    // Búsqueda básica: ILIKE (insensible a mayúsculas)
    // Busca en dos campos "title" y "description"
    params.push(`%${q}%`);
    params.push(`%${q}%`);
    whereParts.push('(title ILIKE $' + (params.length - 1) + ' OR description ILIKE $' + params.length + ')');
  }

  const whereSQL = whereParts.length ? 'WHERE ' + whereParts.join(' AND ') : '';

  // Consultas parametrizadas para evitar inyecciones SQL
  const countSQL = `SELECT COUNT(*)::int AS total FROM items ${whereSQL};`;
  const dataSQL = `
    SELECT id, title, description, created_at
    FROM items
    ${whereSQL}
    ORDER BY created_at DESC
    LIMIT $${params.length + 1} OFFSET $${params.length + 2};
  `;

  try {
    const client = await pool.connect();
    try {
      const countResult = await client.query(countSQL, params);
      const total = countResult.rows[0]?.total ?? 0;

      const dataParams = [...params, limit, offset];
      const dataResult = await client.query(dataSQL, dataParams);

      res.json({
        ok: true,
        total,
        page,
        pageSize: limit,
        rows: dataResult.rows
      });
    } finally {
      client.release();
    }
  } catch (err) {
    err.publicMessage = 'No se pudo completar la búsqueda';
    return next(err);
  }
});

export default router;
