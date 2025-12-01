// Database configuration for Sequelize CLI (CommonJS format)
// This file is specifically for sequelize-cli which requires CommonJS
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const nodeEnv = process.env.NODE_ENV || 'development';
const isProduction = nodeEnv === 'production';

// Helper to get database config from environment
const getDatabaseConfig = () => ({
  url: process.env.DATABASE_URL,
  host: process.env.DATABASE_HOST || 'localhost',
  port: parseInt(process.env.DATABASE_PORT, 10) || 5432,
  name: process.env.DATABASE_NAME || 'viatra_dev',
  user: process.env.DATABASE_USER || 'postgres',
  password: process.env.DATABASE_PASSWORD
});

const config = getDatabaseConfig();

const dbConfig = {
  development: {
    username: config.user,
    password: config.password,
    database: config.name,
    host: config.host,
    port: config.port,
    dialect: 'postgres',
    logging: console.log,
    pool: {
      max: 10,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    dialectOptions: {},
    define: {
      timestamps: true,
      underscored: true,
      freezeTableName: true
    }
  },
  test: {
    username: config.user,
    password: config.password,
    database: process.env.DATABASE_TEST_NAME || 'viatra_test',
    host: config.host,
    port: config.port,
    dialect: 'postgres',
    logging: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    dialectOptions: {},
    define: {
      timestamps: true,
      underscored: true,
      freezeTableName: true
    }
  },
production: {
  use_env_variable: 'DATABASE_URL',
  dialect: 'postgres',
  logging: false,
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false
    }
  },
  pool: {
    max: 20,
    min: 5,
    acquire: 60000,
    idle: 10000
  },
  define: {
    timestamps: true,
    underscored: true,
    freezeTableName: true
  }
}
};


module.exports = dbConfig;
