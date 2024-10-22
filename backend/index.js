const express = require("express");
const cors = require("cors");
const { pool } = require("./db");
const { spawn } = require("child_process")
require("dotenv").config();
const app = express();

app.use(cors());

const schema = process.env.DBSCHEMA;
const PORT = process.env.PORT;

app.get("/", async (req, res) => {
  try {
    const tableName = "studytable";
    const result = await pool.query(`SELECT * FROM ${schema}.${tableName}`);
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.json({ message: "Nö" });
  }
});

app.get("/get", async (req, res) => {
  const pythonProcess = spawn("python3", ["../utils/script.py"]);
  let dataToSend = "";

  pythonProcess.stdout.on("data", (data) => {
    dataToSend += data.toString();
  });

  pythonProcess.stderr.on("data", (data) => {
    res.status(500).send(data.toString());
  });

  pythonProcess.on("close", (code) => {
    try {
      const response = JSON.parse(dataToSend);
      res.json(response);
    } catch (err) {
      res.status(500).send("Error while parsing JSON");
    }
  });
});

app.listen(PORT, () => {
  console.log(`Server läuft http://localhost:${PORT}`);
});
