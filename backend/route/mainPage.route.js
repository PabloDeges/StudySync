const express = require("express");
const router = express.Router();
const { mainPageDisplayInfos, getStundenplan, delTermin } = require("../controller/mainPage.controller.js");
const { changeToSchema } = require("../controller/db.controller.js");
const { authenticateJWT } = require("../utils/authentication.js");


router.get("",mainPageDisplayInfos);

router.get("/stundenplan", changeToSchema, authenticateJWT, getStundenplan);

router.delete("/terminEntfernen", changeToSchema, authenticateJWT, delTermin);

module.exports = router;