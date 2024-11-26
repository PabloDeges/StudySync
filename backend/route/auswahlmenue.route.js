const express = require("express");
const { getStudiengaenge, getSemesterZuStudiengang, getKurseZuSemester, kurseAnwaehlen } = require("../controller/auswahlemenue.controller");
const { changeToSchema } = require("../controller/db.controller");
const { authenticateJWT } = require("../utils/authentication.js")
const router = express.Router();


router.get("/studiengaenge",getStudiengaenge);

router.get("/semester/:studiengangid", getSemesterZuStudiengang);

router.get("/kurse/:semesterid", getKurseZuSemester);

router.post("/kurse", authenticateJWT, kurseAnwaehlen);

module.exports = router;