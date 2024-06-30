const Pool = require("pg").Pool;
require("dotenv").config();

const dbuser = process.env.DBUSER;
const dbpassword = process.env.DBPASSWORD;
const dbhost = process.env.SERVERHOST;
const dbport = process.env.DBPORT;
const dbname = process.env.DBNAME;

const pool = new Pool({
  user: dbuser,
  host: dbhost,
  database: dbname,
  password: dbpassword,
  port: dbport
});

module.exports={
    pool
}
