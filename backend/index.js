const express = require('express');
const cors = require("cors");
const mainPage = require("./route/mainPage.route.js")
const auswahlemenue = require("./route/auswahlmenue.route.js")
const editor = require("./route/editor.route.js")
const pool = require("./model/db.js");
const authRoute = require("./route/auth.route.js")
const { putJsonDataInDb, changeToSchema } = require('./controller/db.controller.js');

require("dotenv").config();
const app = express();

app.use(cors());
app.use(express.json());

app.use("/", changeToSchema, mainPage);
app.use("/auth", changeToSchema, authRoute);
app.use("/auswahlmenue", changeToSchema, auswahlemenue);
app.use("/editor", changeToSchema, editor);

app.listen(process.env.PORT, () => {
    console.log(`Server läuft http://localhost:${process.env.PORT}`);
});

pool.connect()
    .then(()=> console.log("DB erreicht"))
    .catch(err => console.error("Fehler DB", err.stack))
    //nur einkommentieren, wenn inhalte der json in die db geladen werden sollen
    //.then(async () => console.log(await putJsonDataInDb()))