const express = require("express");

const { getStudiengaenge, getSemesterZuStudiengang, getKurseZuSemester, kurseUmwaehlen } = require("../controller/auswahlemenue.controller");
const { changeToSchema } = require("../controller/db.controller");
const { authenticateJWT } = require("../utils/authentication.js")

const router = express.Router();


router.get("/studiengaenge",getStudiengaenge);

router.get("/semester/:studiengangid", getSemesterZuStudiengang);

router.get("/kurse/:semesterid", authenticateJWT, getKurseZuSemester);

router.post("/kurse", authenticateJWT, kurseUmwaehlen);

module.exports = router;