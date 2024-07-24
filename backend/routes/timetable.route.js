const express = require("express");
const router = express.Router();
const { getMainTimetable } = require("../controllers/timetable.controller")

router.get("/",getMainTimetable)

module.exports = router;