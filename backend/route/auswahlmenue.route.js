const express = require("express");
const { getStudiengaenge, getSemesterZuStudiengang, getKurseZuSemester, kurseAnwaehlen } = require("../controller/auswahlemenue.controller");
const { changeToSchema } = require("../controller/db.controller");
const router = express.Router();


router.get("/studiengaenge", changeToSchema,getStudiengaenge);

router.get("/semester/:studiengangid", changeToSchema, getSemesterZuStudiengang);

router.get("/kurse/:semesterid", changeToSchema, getKurseZuSemester);

router.post("/kurse", changeToSchema, kurseAnwaehlen);

module.exports = router;