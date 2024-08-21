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

app.get("/testdata", async (req,res) => {
    try{
        console.log("testdaten angefragt")
        const tableName = "testdata"
        const result = await pool.query(`SELECT * FROM ${schema}.${tableName}`);
        let stringy = result.rows[0]["data"]
        res.json(stringy)

    }catch(error){
        console.error(error)
        res.json({message:"Fehlerchen"})
    }
})

app.listen(PORT, () => {
    console.log(`Server läuft http://localhost:${PORT}`);
});
