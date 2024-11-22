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
		let benutzerid = req.query.userid;
		let anzTermine;
		let kurse = (await pool.query(`SELECT k.id, k.kursname FROM kurs AS k LEFT JOIN studiengang_kurs AS sk ON k.id = sk.kursid WHERE sk.semesterid = ${semesterid} ORDER BY k.kursname ASC, k.id ASC;`)).rows;
		for (let i = 0; i < kurse.length; i++) {
			anzTermine = (await pool.query(`SELECT COUNT(bt.terminid) FROM benutzer_termin AS bt LEFT JOIN termin AS t ON bt.terminid = t.id WHERE bt.benutzerid = ${benutzerid} AND t.kursid = ${kurse[i].id};`)).rows[0].count;
			kurse[i].isChecked = (anzTermine > 0);
		}
		res.status(200).json(kurse);
	} catch (err) {
		res.status(500).json({ message: err.message });
	}
};

const kurseUmwaehlen = async (req, res) => {
	try {
		let benutzerid = req.body.userid;
		let semesterid = req.body.semesterid;
		let neueKurse = req.body.newkursids;
		let entfKurse = req.body.delkursids;
		let termine;
		let eingefuegteTermine = [];
		let entfernteTermine = [];
		let response;
		for (let i = 0; i < neueKurse.length; i++) {
			//termine = (await pool.query(`SELECT t.id FROM studiengang_kurs AS sk LEFT JOIN termin as t ON sk.kursid = t.kursid WHERE sk.semesterid = ${semesterid} AND sk.kursid = ${neueKurse[i].id};`)).rows;
			termine = (await pool.query(`SELECT t.id FROM studiengang_kurs AS sk LEFT JOIN termin as t ON sk.kursid = t.kursid WHERE sk.kursid = ${neueKurse[i].id};`)).rows;
			for (let j = 0; j < termine.length; j++) {
				//existiert keine id fuer die kombination aus kurs, doz, wochentag und startzeit, wird ein neuer eintrag hinzugefuegt
				if ((await pool.query(`SELECT COUNT(benutzerid) FROM benutzer_termin WHERE benutzerid='${benutzerid}' AND terminid='${termine[j].id}';`)).rows[0].count == 0) {
					await pool.query(`INSERT INTO benutzer_termin (benutzerid, terminid) VALUES (${benutzerid}, ${termine[j].id})`);
					eingefuegteTermine.push(termine[j].id);
				}
			}
		}
		for (let i = 0; i < entfKurse.length; i++) {
			let anzDel = (await pool.query(`DELETE FROM benutzer_termin AS bt USING termin AS t WHERE bt.terminid = t.id AND bt.benutzerid = ${benutzerid} AND t.kursid = ${entfKurse[i].id};`)).rowCount;
			entfernteTermine.push({"kursid": entfKurse[i].id, "anzDel": anzDel});
		}
		response = {"neueTermine": eingefuegteTermine, "entfernteTermine": entfernteTermine}
		res.status(200).json(response);
	} catch (err) {
		res.status(500).json({ message: err.message });
	}
};

module.exports = {
	getStudiengaenge,
	getSemesterZuStudiengang,
	getKurseZuSemester,
	kurseUmwaehlen
};