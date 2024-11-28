const express = require("express");
const router = express.Router();
const { getStundenplan, delTermin , editKommentar } = require("../controller/mainPage.controller.js");
const { changeToSchema } = require("../controller/db.controller.js");
const { authenticateJWT } = require("../utils/authentication.js");

router.get("/stundenplan", changeToSchema, authenticateJWT, getStundenplan);

router.delete("/terminEntfernen", changeToSchema, authenticateJWT, delTermin);

router.post('/editKommentar',changeToSchema,editKommentar);

module.exports = router;