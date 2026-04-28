const express = require("express");
const cors = require("cors");
const fs = require("fs");
const path = require("path");

const app = express();
app.use(cors());
app.use(express.json({ limit: "1mb" }));

const DB_PATH = path.join(__dirname, "db.json");
const PORT = process.env.PORT ? Number(process.env.PORT) : 3001;

function readDb() {
  const raw = fs.readFileSync(DB_PATH, "utf8");
  const parsed = JSON.parse(raw);
  if (!parsed || typeof parsed !== "object") throw new Error("Invalid db.json");
  if (!Array.isArray(parsed.products)) parsed.products = [];
  if (typeof parsed.nextId !== "number") {
    const maxId = parsed.products.reduce((m, p) => Math.max(m, Number(p.id) || 0), 0);
    parsed.nextId = maxId + 1;
  }
  return parsed;
}

function writeDb(db) {
  fs.writeFileSync(DB_PATH, JSON.stringify(db, null, 2) + "\n", "utf8");
}

function asNumber(value) {
  if (value === null || value === undefined || value === "") return null;
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
}

function validateProductInput(body, { partial }) {
  const errors = [];

  const maybe = (key) => body && Object.prototype.hasOwnProperty.call(body, key);

  const imageUrl = maybe("imageUrl") ? body.imageUrl : undefined;
  const name = maybe("name") ? body.name : undefined;
  const type = maybe("type") ? body.type : undefined;
  const price = maybe("price") ? body.price : undefined;

  if (!partial || imageUrl !== undefined) {
    if (typeof imageUrl !== "string" || imageUrl.trim().length === 0) {
      errors.push("imageUrl must be a non-empty string");
    }
  }
  if (!partial || name !== undefined) {
    if (typeof name !== "string" || name.trim().length === 0) {
      errors.push("name must be a non-empty string");
    }
  }
  if (!partial || type !== undefined) {
    if (typeof type !== "string" || type.trim().length === 0) {
      errors.push("type must be a non-empty string");
    }
  }
  if (!partial || price !== undefined) {
    const n = asNumber(price);
    if (n === null) errors.push("price must be a number");
    else if (n < 0) errors.push("price must be >= 0");
  }

  return { ok: errors.length === 0, errors };
}

app.get("/health", (_req, res) => {
  res.json({ ok: true });
});

app.get("/products", (req, res) => {
  const db = readDb();
  let products = db.products.slice();

  const q = typeof req.query.q === "string" ? req.query.q.trim().toLowerCase() : "";
  if (q) {
    products = products.filter((p) => {
      const hay = `${p.name ?? ""} ${p.type ?? ""}`.toLowerCase();
      return hay.includes(q);
    });
  }

  res.json(products);
});

app.get("/products/:id", (req, res) => {
  const id = asNumber(req.params.id);
  if (id === null) return res.status(400).json({ error: "Invalid id" });

  const db = readDb();
  const product = db.products.find((p) => Number(p.id) === id);
  if (!product) return res.status(404).json({ error: "Product not found" });

  res.json(product);
});

app.post("/products", (req, res) => {
  const validation = validateProductInput(req.body, { partial: false });
  if (!validation.ok) return res.status(400).json({ error: "Validation failed", details: validation.errors });

  const db = readDb();
  const product = {
    id: db.nextId++,
    imageUrl: req.body.imageUrl.trim(),
    name: req.body.name.trim(),
    type: req.body.type.trim(),
    price: asNumber(req.body.price),
  };
  db.products.push(product);
  writeDb(db);
  res.status(201).json(product);
});

app.put("/products/:id", (req, res) => {
  const id = asNumber(req.params.id);
  if (id === null) return res.status(400).json({ error: "Invalid id" });

  const validation = validateProductInput(req.body, { partial: false });
  if (!validation.ok) return res.status(400).json({ error: "Validation failed", details: validation.errors });

  const db = readDb();
  const idx = db.products.findIndex((p) => Number(p.id) === id);
  if (idx === -1) return res.status(404).json({ error: "Product not found" });

  const updated = {
    id,
    imageUrl: req.body.imageUrl.trim(),
    name: req.body.name.trim(),
    type: req.body.type.trim(),
    price: asNumber(req.body.price),
  };

  db.products[idx] = updated;
  writeDb(db);
  res.json(updated);
});

app.patch("/products/:id", (req, res) => {
  const id = asNumber(req.params.id);
  if (id === null) return res.status(400).json({ error: "Invalid id" });

  const validation = validateProductInput(req.body, { partial: true });
  if (!validation.ok) return res.status(400).json({ error: "Validation failed", details: validation.errors });

  const db = readDb();
  const idx = db.products.findIndex((p) => Number(p.id) === id);
  if (idx === -1) return res.status(404).json({ error: "Product not found" });

  const current = db.products[idx];
  const next = { ...current };

  if (Object.prototype.hasOwnProperty.call(req.body, "imageUrl")) next.imageUrl = String(req.body.imageUrl).trim();
  if (Object.prototype.hasOwnProperty.call(req.body, "name")) next.name = String(req.body.name).trim();
  if (Object.prototype.hasOwnProperty.call(req.body, "type")) next.type = String(req.body.type).trim();
  if (Object.prototype.hasOwnProperty.call(req.body, "price")) next.price = asNumber(req.body.price);

  db.products[idx] = next;
  writeDb(db);
  res.json(next);
});

app.delete("/products/:id", (req, res) => {
  const id = asNumber(req.params.id);
  if (id === null) return res.status(400).json({ error: "Invalid id" });

  const db = readDb();
  const before = db.products.length;
  db.products = db.products.filter((p) => Number(p.id) !== id);
  if (db.products.length === before) return res.status(404).json({ error: "Product not found" });

  writeDb(db);
  res.status(204).send();
});

app.listen(PORT, () => {
  console.log(`Products API running on http://localhost:${PORT}`);
});

