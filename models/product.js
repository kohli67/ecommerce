'use strict';
module.exports = (sequelize, DataTypes) => {
  const Product = sequelize.define('Product', {
    productName: DataTypes.STRING,
    price: DataTypes.FLOAT,
    categoryId: DataTypes.INTEGER // optional, if you want to link to Category
  }, {});
  return Product;
};
