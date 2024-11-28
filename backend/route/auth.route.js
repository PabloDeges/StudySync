const express = require("express");
const router = express.Router();
const { registierung, login , authToken} = require("../controller/auth.controller.js");
const { authenticateJWT } = require("../utils/authentication.js");

router.post("/register", registierung);

router.post("/login", login);

router.get("/authToken", authenticateJWT, authToken)

module.exports = router;
