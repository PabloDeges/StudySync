const express = require('express');
const cors = require("cors");
const {pool} = require("./db")
require("dotenv").config();
const app = express();

app.use(cors());

const schema = process.env.DBSCHEMA;
const PORT = process.env.PORT;

app.get("/", async (req,res) => {
    try{
        const tableName = "studytable"
        const result = await pool.query(`SELECT * FROM ${schema}.${tableName}`);
        res.json(result.rows)
    }catch(error){
        console.error(error)
        res.json({message:"Nö"})
    }
})

app.listen(PORT, () => {
    console.log(`Server läuft http://localhost:${PORT}`);
});
