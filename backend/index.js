const express = require('express');
const cors = require("cors");
const mainPage = require("./route/mainPage.route.js")

require("dotenv").config();
const app = express();

app.use(cors());

const schema = process.env.DBSCHEMA;
const PORT = process.env.PORT;

app.use("/",mainPage);

app.listen(PORT, () => {
    console.log(`Server läuft http://localhost:${PORT}`);
});
