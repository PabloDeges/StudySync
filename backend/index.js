const express = require('express');
const cors = require("cors");
const mainPage = require("./route/mainPage.route.js")
const pool = require("./model/db.js")

require("dotenv").config();
const app = express();

app.use(cors());

app.use("/",mainPage);

app.listen(process.env.PORT, () => {
    console.log(`Server läuft http://localhost:${process.env.PORT}`);
});

pool.connect()
    .then(()=> console.log("DB erreicht"))
    .catch(err => console.error("Fehler DB", err.stack))