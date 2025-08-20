const express = require('express');
const router = express.Router();
const { Product } = require('../models');

// Create Product
router.post('/', async (req, res) => {
  try {
    const product = await Product.create(req.body);
    res.json(product);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all Products
router.get('/', async (req, res) => {
  try {
    const products = await Product.findAll();
    res.json(products);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get Product by ID
router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findByPk(req.params.id);
    res.json(product);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update Product
router.put('/:id', async (req, res) => {
  try {
    await Product.update(req.body, { where: { id: req.params.id } });
    res.json({ message: 'Product updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete Product
router.delete('/:id', async (req, res) => {
  try {
    await Product.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Product deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
