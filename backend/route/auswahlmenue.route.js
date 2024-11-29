const express = require("express");

const { getStudiengaenge, getSemesterZuStudiengang, getKurseZuSemester, kurseUmwaehlen, alleTermineEinesBenutzersLoe } = require("../controller/auswahlemenue.controller");
const { authenticateJWT } = require("../utils/authentication.js")

const router = express.Router();


router.get("/studiengaenge",getStudiengaenge);

router.get("/semester/:studiengangid", getSemesterZuStudiengang);

router.get("/kurse/:semesterid", authenticateJWT, getKurseZuSemester);

router.post("/kurse", authenticateJWT, kurseUmwaehlen);

router.delete("/termine", authenticateJWT, alleTermineEinesBenutzersLoe);

module.exports = router;