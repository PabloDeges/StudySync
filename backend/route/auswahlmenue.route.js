const express = require("express");
const { getStudiengaenge, getSemesterZuStudiengang, getKurseZuSemester, kurseUmwaehlen } = require("../controller/auswahlemenue.controller");
const router = express.Router();


router.get("/studiengaenge",getStudiengaenge);

router.get("/semester/:studiengangid", getSemesterZuStudiengang);

router.get("/kurse/:semesterid", getKurseZuSemester);

router.post("/kurse", kurseUmwaehlen);

module.exports = router;