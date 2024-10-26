const express = require('express');
const cors = require("cors");
const mainPage = require("./route/mainPage.route.js")
const pool = require("./model/db.js");
const { putJsonDataInDb } = require('./controller/db.controller.js');

require("dotenv").config();
const app = express();
const schema = process.env.DBSCHEMA;

app.use(cors());

app.use("/",mainPage);

app.listen(process.env.PORT, () => {
    console.log(`Server läuft http://localhost:${process.env.PORT}`);
});

pool.connect()
    .then(()=> console.log("DB erreicht"))
    .catch(err => console.error("Fehler DB", err.stack))
    .then(async () => console.log(await changeToSchema()))
    //nur einkommentieren, wenn inhalte der json in die db geladen werden sollen
    //.then(async () => console.log(await putJsonDataInDb()))

async function changeToSchema() {
    if((await pool.query(`SELECT schema_name FROM information_schema.schemata WHERE schema_name = '${schema}'`)).rowCount == 1) {
        return pool.query("SET Search_Path TO " + schema)
            .then(() => "Schema \"" + schema + "\" eingestellt")
            .catch(() => "Fehler beim einstellen des Schemas \"" + schema + "\"");
    }
    return "Schema \"" + schema + "\" nicht gefunden";
}