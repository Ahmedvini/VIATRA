// Database configuration for Sequelize CLI
// IMPORTANT: هذا الملف مستقل ولا يعتمد على config/index.js
// حتى نتجنّب الـ circular dependency

import dotenv from 'dotenv';

dotenv.config();

const isProduction = process.env.NODE_ENV === 'production';

const common = {
  username: process.env.DB_USER || process.env.DATABASE_USER || 'postgres',
  password: process.env.DB_PASSWORD || process.env.DATABASE_PASSWORD || null,
  database: process.env.DB_NAME || process.env.DATABASE_NAME || 'viatra',
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 5432,
  dialect: 'postgres',
  pool: {
    max: 10,
    min: 0,
    acquire: 30000,
    idle: 10000
  },
  define: {
    timestamps: true,
    underscored: true,
    freezeTableName: true
  }
};

const dbConfig = {
  development: {
    ...common,
    logging: console.log
  },
  test: {
    ...common,
    database: process.env.DATABASE_TEST_NAME || process.env.DB_TEST_NAME || 'viatra_test',
    logging: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  },
  production: {
    ...common,
    logging: false,
    ssl: isProduction,
    dialectOptions: isProduction
      ? {
          ssl: {
            require: true,
            rejectUnauthorized: false
          }
        }
      : {},
    pool: {
      max: 20,
      min: 5,
      acquire: 60000,
      idle: 10000
    }
  }
};

export default dbConfig;
