'use strict';
module.exports = (sequelize, DataTypes) => {
  const Category = sequelize.define('Category', {
    categoryName: DataTypes.STRING
  }, {});
  return Category;
};
