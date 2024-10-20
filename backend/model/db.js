const { Pool } = require('pg');
require("dotenv").config();

const pool = new Pool({
    user: process.env.DBUSER,
    host: process.env.SERVERHOST,
    database: process.env.DBNAME,
    password: process.env.DBPASSWORD,
    port: process.env.DBPORT
})

module.exports = pool
