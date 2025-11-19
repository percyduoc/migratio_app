# Migratio App (Flutter)


---

## 1) Backend (Postgres + Node `vision-api`)

### 1.1 SQL – Tabla de usuarios (app)

Habilitar extensión (si no existe):

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

Crear tabla:

```sql
CREATE TABLE IF NOT EXISTS usuarios_app (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre        TEXT NOT NULL,
  apellido      TEXT NOT NULL,
  email         TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  tipo_usuario  TEXT NOT NULL CHECK (tipo_usuario IN ('admin','empleador','trabajador')),
  activo        BOOLEAN NOT NULL DEFAULT TRUE,
  eliminado     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 1.2 Endpoint **lugares + status**



```js
app.get('/api/lugares/status', async (_req, res) => {
  try {
    const client = await pool.connect();
    try {
      const q = `
        SELECT
          l.id, l.nombre, l.lat, l.lon, l.capacidad_maxima,
          c.id AS camara_id
        FROM lugares l
        LEFT JOIN camaras c ON c.lugar_id = l.id AND c.habilitada = true
        WHERE l.activo = true
      `;
      const { rows } = await client.query(q);
      const out = [];
      for (const r of rows) {
        let countNow = null;
        if (r.camara_id) {
          const m = await client.query(
            'SELECT count FROM metricas WHERE camara_id = $1 ORDER BY ts DESC LIMIT 1',
            [r.camara_id]
          );
          if (m.rowCount) countNow = Number(m.rows[0].count || 0);
        }
        let semaforo = null;
        if (r.capacidad_maxima && r.capacidad_maxima > 0 && countNow != null) {
          const pct = Math.min(100, Math.round((countNow / r.capacidad_maxima) * 100));
          if (pct <= 30) semaforo = 'verde';
          else if (pct < 70) semaforo = 'amarillo';
          else semaforo = 'rojo';
        }
        out.push({
          id: r.id,
          nombre: r.nombre,
          lat: Number(r.lat),
          lon: Number(r.lon),
          capacidad_maxima: r.capacidad_maxima,
          count_now: countNow,
          semaforo,
        });
      }
      res.json(out);
    } finally {
      client.release();
    }
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'server_error' });
  }
});
```

### 1.3 Auth **JWT** (signup/login/me)

Instala dependencias:

```bash
npm i bcryptjs jsonwebtoken
```

Agrega `JWT_SECRET` a tu `.env`:

```
JWT_SECRET=ultra_secreto_cambia_esto
```

Pega en `server.js` (o separa a `auth.js`) lo siguiente:

```js
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

function signJwt(payload) {
  return jwt.sign(payload, process.env.JWT_SECRET || 'dev', { expiresIn: '7d' });
}
function authMiddleware(req, res, next) {
  const h = req.headers.authorization || '';
  if (!h.startsWith('Bearer ')) return res.status(401).json({ error: 'no_token' });
  try {
    req.user = jwt.verify(h.slice(7), process.env.JWT_SECRET || 'dev');
    next();
  } catch {
    res.status(401).json({ error: 'bad_token' });
  }
}

// POST /api/auth/signup
app.post('/api/auth/signup', async (req, res) => {
  try {
    const { nombre, apellido, email, password, tipo_usuario='trabajador' } = req.body || {};
    if (!email || !password || !nombre || !apellido) return res.status(400).json({ error: 'missing' });
    const client = await pool.connect();
    try {
      const dup = await client.query('SELECT 1 FROM usuarios_app WHERE email=$1 LIMIT 1', [email]);
      if (dup.rowCount) return res.status(409).json({ error: 'email_exists' });
      const hash = await bcrypt.hash(password, 10);
      const ins = await client.query(
        'INSERT INTO usuarios_app (nombre, apellido, email, password_hash, tipo_usuario) VALUES ($1,$2,$3,$4,$5) RETURNING id,nombre,apellido,email,tipo_usuario',
        [nombre, apellido, email, hash, tipo_usuario]
      );
      res.json({ ok: true, user: ins.rows[0] });
    } finally {
      client.release();
    }
  } catch (e) {
    console.error(e); res.status(500).json({ error: 'server_error' });
  }
});

// POST /api/auth/login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body || {};
    const client = await pool.connect();
    try {
      const q = await client.query('SELECT * FROM usuarios_app WHERE email=$1 AND eliminado=false', [email]);
      if (!q.rowCount) return res.status(401).json({ error: 'bad_credentials' });
      const u = q.rows[0];
      const ok = await bcrypt.compare(password, u.password_hash);
      if (!ok) return res.status(401).json({ error: 'bad_credentials' });
      const token = signJwt({ sub: u.id, email: u.email, tipo: u.tipo_usuario });
      res.json({
        token,
        user: { id: u.id, nombre: u.nombre, apellido: u.apellido, email: u.email, tipo_usuario: u.tipo_usuario }
      });
    } finally { client.release(); }
  } catch (e) { console.error(e); res.status(500).json({ error: 'server_error' }); }
});

// GET /api/users/me
app.get('/api/users/me', authMiddleware, async (req, res) => {
  const client = await pool.connect();
  try {
    const q = await client.query('SELECT id,nombre,apellido,email,tipo_usuario FROM usuarios_app WHERE id=$1', [req.user.sub]);
    if (!q.rowCount) return res.status(404).json({ error: 'not_found' });
    res.json(q.rows[0]);
  } finally { client.release(); }
});

// PUT /api/users/me
app.put('/api/users/me', authMiddleware, async (req, res) => {
  const { nombre, apellido, tipo_usuario } = req.body || {};
  const client = await pool.connect();
  try {
    const q = await client.query(
      'UPDATE usuarios_app SET nombre=COALESCE($1,nombre), apellido=COALESCE($2,apellido), tipo_usuario=COALESCE($3,tipo_usuario), updated_at=now() WHERE id=$4 RETURNING id,nombre,apellido,email,tipo_usuario',
      [nombre, apellido, tipo_usuario, req.user.sub]
    );
    res.json(q.rows[0]);
  } finally { client.release(); }
});
```


---

## 2) Ejecutar la app

1) Edita `lib/config.dart` y pon la  `apiBaseUrl`
2) En la raíz del proyecto:
   ```bash
   flutter pub get
   # Para web (rápido): 
   flutter run -d chrome
   # Para Android/iOS, concede permisos de geolocalización y crea plataformas si faltan:
   flutter create .
   flutter run
   ```

**Permisos ubicación** (Android `AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

---

