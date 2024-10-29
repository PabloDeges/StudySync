const express = require('express');
const cors = require("cors");
const mainPage = require("./route/mainPage.route.js")
const auswahlemenue = require("./route/auswahlmenue.route.js")
const pool = require("./model/db.js");
const { putJsonDataInDb, changeToSchema } = require('./controller/db.controller.js');

require("dotenv").config();
const app = express();

app.use(cors());
app.use(express.json())

app.use("/",mainPage);
app.use("/auswahlmenue",auswahlemenue);

app.listen(process.env.PORT, () => {
    console.log(`Server läuft http://localhost:${process.env.PORT}`);
});

pool.connect()
    .then(()=> console.log("DB erreicht"))
    .catch(err => console.error("Fehler DB", err.stack))
    .then(async () => console.log(await changeToSchema()))
    //nur einkommentieren, wenn inhalte der json in die db geladen werden sollen
    //.then(async () => console.log(await putJsonDataInDb()))