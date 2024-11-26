const pool = require("../model/db");

const getStudiengaenge = async (req, res) => {
	try {
		let studiengaenge = (await pool.query("SELECT id, CONCAT(studiengangname,' - ',studiengangart) as studiengang FROM studiengang;")).rows;
		res.status(200).json(studiengaenge);
	} catch (err) {
		res.status(500).json({ message: err.message });
	}
};

const getSemesterZuStudiengang = async (req, res) => {
	try {
		let studiengangid = req.params.studiengangid;
		let semester = (await pool.query(`SELECT DISTINCT s.id, s.semesterkennung FROM semester as s LEFT JOIN studiengang_kurs as sk ON s.id = sk.semesterid WHERE sk.studiengangid = ${studiengangid} ORDER BY s.semesterkennung ASC, s.id asc;`)).rows;
		res.status(200).json(semester);
	} catch (err) {
		res.status(500).json({ message: err.message });
	}
};

const getKurseZuSemester = async (req, res) => {
	try {
		let semesterid = req.params.semesterid;
		let kurse = (await pool.query(`SELECT k.id, k.kursname FROM kurs AS k LEFT JOIN studiengang_kurs AS sk ON k.id = sk.kursid WHERE sk.semesterid = ${semesterid} ORDER BY k.kursname ASC, k.id ASC;`)).rows;
		res.status(200).json(kurse);
	} catch (err) {
		res.status(500).json({ message: err.message });
	}
};

const kurseAnwaehlen = async (req, res) => {
	try {
		let benutzerid = req.query.userid;
		let semesterid = req.body.semesterid;
		let kurse = req.body.kursids;
		let termine;
		let eingefuegteTermine = [];
		for (let i = 0; i < kurse.length; i++) {
			termine = (await pool.query(`SELECT t.id FROM studiengang_kurs AS sk LEFT JOIN termin as t ON sk.kursid = t.kursid WHERE sk.semesterid = ${semesterid} AND sk.kursid = ${kurse[i].id};`)).rows;
			for (let j = 0; j < termine.length; j++) {
				//existiert keine id fuer die kombination aus kurs, doz, wochentag und startzeit, wird ein neuer eintrag hinzugefuegt
				if ((await pool.query(`SELECT COUNT(benutzerid) FROM benutzer_termin WHERE benutzerid='${benutzerid}' AND terminid='${termine[j].id}';`)).rows[0].count == 0) {
					await pool.query(`INSERT INTO benutzer_termin (benutzerid, terminid) VALUES (${benutzerid}, ${termine[j].id})`);
					eingefuegteTermine.push(termine[j].id);
				}
			}
		}
		res.status(200).json(eingefuegteTermine);
	} catch (err) {
		res.status(500).json({ message: err.message });
	}
};

module.exports = {
	getStudiengaenge,
	getSemesterZuStudiengang,
	getKurseZuSemester,
	kurseAnwaehlen
};