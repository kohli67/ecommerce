const express = require("express");
const { sequelize, Category, Product, Attribute } = require("./models");

const app = express();
app.use(express.json());
const PORT = process.env.PORT || 3000;

// --- CATEGORY CRUD ---
app.post("/categories", async (req, res) => {
  const category = await Category.create(req.body);
  res.json(category);
});
app.get("/categories", async (req, res) => {
  const categories = await Category.findAll();
  res.json(categories);
});

// --- PRODUCT CRUD ---
app.post("/products", async (req, res) => {
  const product = await Product.create(req.body);
  res.json(product);
});
app.get("/products", async (req, res) => {
  const products = await Product.findAll();
  res.json(products);
});

// --- ATTRIBUTE CRUD ---
app.post("/attributes", async (req, res) => {
  const attribute = await Attribute.create(req.body);
  res.json(attribute);
});
app.get("/attributes", async (req, res) => {
  const attributes = await Attribute.findAll();
  res.json(attributes);
});

app.listen(PORT, async () => {
  console.log(`Server running on port ${PORT}`);
  await sequelize.authenticate();
  console.log("Database connected!");
});
