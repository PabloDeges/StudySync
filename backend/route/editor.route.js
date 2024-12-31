const express = require("express");

const { authenticateJWT } = require("../utils/authentication.js");
const { postCustomStrings, delKollisionen, delEinzelTermin } = require("../controller/editor.controller.js");

const router = express.Router();

router.post("/customStrings", authenticateJWT, postCustomStrings);

router.delete("/kollisionen", authenticateJWT, delKollisionen);

router.delete("/delTermin", authenticateJWT, delEinzelTermin);

module.exports = router;