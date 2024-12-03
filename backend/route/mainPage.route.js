const express = require("express");
const router = express.Router();
const { getStundenplan, delTermin , editKommentar } = require("../controller/mainPage.controller.js");
const { changeToSchema } = require("../controller/db.controller.js");
const { authenticateJWT } = require("../utils/authentication.js");

router.get("/stundenplan", authenticateJWT, getStundenplan);

router.delete("/terminEntfernen", authenticateJWT, delTermin);

router.post('/editKommentar', editKommentar);

module.exports = router;