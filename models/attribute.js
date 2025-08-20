'use strict';
module.exports = (sequelize, DataTypes) => {
  const Attribute = sequelize.define('Attribute', {
    attributeName: DataTypes.STRING,
    attributeValue: DataTypes.STRING
  }, {});
  return Attribute;
};
