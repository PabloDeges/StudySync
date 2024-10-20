const express = require("express");
const router = express.Router();
const { mainPageDisplayInfos } = require("../controller/mainPage.controller.js");


router.get("",mainPageDisplayInfos);

module.exports = router;