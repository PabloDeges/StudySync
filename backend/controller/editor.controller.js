const pool = require("../model/db");

const postCustomStrings = async (req, res) => {
	try {
        let benutzerid = req.query.userid;
        let terminid = req.body.terminid;
        let kommentar = req.body.comment;
        let link = req.body.link;
        let mail = req.body.mail;
        let anzMod = (await pool.query(`UPDATE benutzer_termin SET kommentar = '${kommentar}', kurslink = '${link}' WHERE benutzerid = ${benutzerid} AND terminid = ${terminid}`)).rowCount;
		res.status(200).json(anzMod);
	} catch (err) {
		res.status(500).json({ message: err.message });
	}
};

const delKollisionen = async (req, res) => {
    try {
        let benutzerid = req.query.userid;
        let terminid = req.body.terminid;
        let wochentag = req.body.day;
        let startzeit = req.body.time.toString();
        startzeit = startzeit.substring(0,2) + ":" + startzeit.substring(2);
        let anzDel = (await pool.query(`DELETE FROM benutzer_termin WHERE benutzerid = ${benutzerid} AND terminid IN (SELECT t.id FROM benutzer_termin AS bt LEFT JOIN termin AS t ON bt.terminid = t.id WHERE bt.benutzerid = ${benutzerid} AND t.wochentag = '${wochentag}' AND t.startzeit = '${startzeit}' AND t.id != ${terminid});`)).rowCount;
        res.status(200).json(anzDel);
    } catch (err) {
        res.status(500).json({message: err.message});
    }
}

module.exports = {
    postCustomStrings,
    delKollisionen
};