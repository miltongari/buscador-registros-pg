/**
 * Servidor Express para API de búsqueda.
 * Incluye:
 *  - Seguridad básica (Helmet, CORS)
 *  - Logs (morgan)
 *  - Rate Limiting
 *  - Rutas: /api/health y /api/search
 */

import empresasRouter from './routes/empresas.js';

import 'dotenv/config';              // Carga variables de entorno desde .env
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';

import searchRouter from './routes/search.js';

const app = express();

// Middlewares básicos
app.use(helmet());
app.use(express.json());

// CORS: permite al frontend acceder a la API
const allowedOrigin = process.env.CORS_ORIGIN || 'http://localhost:5173';
app.use(cors({ origin: allowedOrigin }));

// Logs en consola
app.use(morgan('dev'));

// Rate limiting: evita abuso (ajusta según tu caso)
const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minuto
  max: 120,            // 120 requests/min por IP
});
app.use(limiter);

// Rutas
app.get('/api/health', (req, res) => {
  res.json({ ok: true, timestamp: new Date().toISOString() });
});

app.use('/api/empresas', empresasRouter);

// Manejador global de errores
app.use((err, req, res, next) => {
  console.error('[ERROR]', err);
  const status = err.status || 500;
  res.status(status).json({
    ok: false,
    message: err.publicMessage || 'Error interno del servidor',
    // En producción no envíes err.stack
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
  });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`✅ API escuchando en http://localhost:${PORT}`);
});
