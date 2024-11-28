const pool = require("../model/db");

const getStundenplan = async (req, res) => {
	try {
		let userid = req.query.userid;
		let daten = (await pool.query(`SELECT t.id AS terminid, k.kursname, k.kurskuerzel, d.dozname, d.dozkuerzel, t.terminart, t.wochentag, t.startzeit, t.dauer, t.raum, bt.terminstartverzoegerung, bt.kommentar FROM termin AS t LEFT JOIN benutzer_termin AS bt ON t.id = bt.terminid LEFT JOIN doz AS d ON t.dozid = d.id LEFT JOIN kurs AS k ON t.kursid = k.id WHERE bt.benutzerid = ${userid};`)).rows;
		let startzeit, terminstartverzoegerung;
		//terminstartverzoegerung wird auf die startzeit gerechnet und anschliessend aus dem datensatz entfernt
		for (let i = 0; i < daten.length; i++) {
			startzeit = daten[i].startzeit.split(":");
			terminstartverzoegerung = daten[i].terminstartverzoegerung;
			startzeit[0] = parseInt(startzeit[0]) + Math.floor(terminstartverzoegerung/60);
			startzeit[1] = parseInt(startzeit[1]) + (terminstartverzoegerung % 60);
			startzeit = startzeit[0]*100 + startzeit[1];
			daten[i].startzeit = startzeit;
			delete daten[i].terminstartverzoegerung;
		}
		res.status(200).json({'data' : daten});
	} catch (err) {
		res.status(500).json({ message: err.message });
	}
}

const delTermin = async (req, res) => {
	try {
		let userid = req.query.userid;
		let terminid = req.body.terminid;
		let daten = await pool.query(`DELETE FROM benutzer_termin WHERE benutzerid = ${userid} AND terminid = ${terminid};`);
		res.status(200).json({"geloeschteZeilen":daten.rowCount});
	} catch (err) {
		res.status(500).json({ message: err.message });
	}
}

const editKommentar =async (req,res) => {
	try{
		console.log(req.body.kommentar);
		if(req.body.kommentar == undefined){
			res.status(500).json({"message":"Felher"})
		}else{
			res.status(200).json({"message":req.body.kommentar})
		}
	}catch(err){

	}
}

module.exports = {
	getStundenplan,
	delTermin,
	editKommentar
};
