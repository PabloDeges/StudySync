const express = require("express");
const router = express.Router();
const { mainPageDisplayInfos, getStundenplan, delTermin } = require("../controller/mainPage.controller.js");
const { changeToSchema } = require("../controller/db.controller.js");


router.get("",mainPageDisplayInfos);

router.get("/stundenplan", changeToSchema, getStundenplan);

router.delete("/terminEntfernen", changeToSchema, delTermin);

module.exports = router;