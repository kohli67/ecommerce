const express = require('express');
const router = express.Router();
const { Attribute } = require('../models');

// Create Attribute
router.post('/', async (req, res) => {
  try {
    const attribute = await Attribute.create(req.body);
    res.json(attribute);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all Attributes
router.get('/', async (req, res) => {
  try {
    const attributes = await Attribute.findAll();
    res.json(attributes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get Attribute by ID
router.get('/:id', async (req, res) => {
  try {
    const attribute = await Attribute.findByPk(req.params.id);
    res.json(attribute);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update Attribute
router.put('/:id', async (req, res) => {
  try {
    await Attribute.update(req.body, { where: { id: req.params.id } });
    res.json({ message: 'Attribute updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete Attribute
router.delete('/:id', async (req, res) => {
  try {
    await Attribute.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Attribute deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
