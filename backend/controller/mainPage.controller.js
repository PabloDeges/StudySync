//const dataFormat = require("../model/mainPage.model.js");
const fs = require("fs");

const mainPageDisplayInfos = async (req, res) => {
  try {
    let daten = readJsonFile("./mainData.json");
    res.status(200).json(daten);
  } catch (err) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  mainPageDisplayInfos,
};

function readJsonFile(filePath) {
  const data = fs.readFileSync(filePath, "utf8");
  const jsonData = JSON.parse(data);
  return jsonData;
}
