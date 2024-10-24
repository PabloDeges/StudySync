const fs = require("fs");
const pool = require("../model/db");

const mainPageDisplayInfos = async (req, res) => {
	try {
		let daten = readJsonFile("./mainData.json");
		res.status(200).json(daten);
	} catch (err) {
		res.status(500).json({ message: error.message });
	}
};

module.exports = {
	mainPageDisplayInfos,
	putJsonDataInDb
};

async function putJsonDataInDb() {
	let data = readJsonFile("./stundenplaene.json")["stundenplaene"];
	let currentStudy, currentStudyName, currentSemester, currentWeek, currentEntry;
	let currentKurs, currentDoz;
	let currentStudyId, currentKursId, currentDozId;

	for (let i = 0; i < data.length; i++) {
		//der name des aktuellen studiengangs wird von seinem kuerzel getrennt und sonderzeichen werden entfernt
		currentStudy = data[i]["studiengang"].split("-");
		currentStudyName = currentStudy[1].split(".")[0].replace(/[0-9]/, "");
		currentSemester = currentStudy[0];

		//pruefe, ob ein studiengang mit dem aktuellen namen bereits eine id in der db hat
		if ((await pool.query(`SELECT COUNT(id) FROM studiengang WHERE studiengangname='${currentStudyName}';`)).rows[0].count == 0) {
			//existiert keine id fuer den entsprechenden namen, wird ein neuer eintrag hinzugefuegt
			await pool.query(`INSERT INTO studiengang (studiengangname) VALUES ('${currentStudyName}');`);
		}
		//die id des zuvor, oder nun existierende eintrags mit dem aktuellen namen wird aus der db geholt
		currentStudyId = (await pool.query(`SELECT id FROM studiengang WHERE studiengangname='${currentStudyName}';`)).rows[0].id;
		
		currentWeek = data[i]["stundenplan"];

		for (let j = 0; j < currentWeek.length; j++) {
			currentEntry = currentWeek[j];

			currentDoz = currentEntry["dozent"];
			//pruefe, ob ein dozent mit dem aktuellen namen bereits eine id in der db hat
			if ((await pool.query(`SELECT COUNT(id) FROM doz WHERE dozname='${currentDoz}';`)).rows[0].count == 0) {
				//existiert keine id fuer den entsprechenden namen, wird ein neuer eintrag hinzugefuegt
				await pool.query(`INSERT INTO doz (dozname, dozkuerzel) VALUES ('${currentDoz}', '${currentDoz.substring(0, 3)}');`);
			}
			//die id des zuvor, oder nun existierende eintrags mit dem aktuellen namen wird aus der db geholt
			currentDozId = (await pool.query(`SELECT id FROM doz WHERE dozname='${currentDoz}';`)).rows[0].id;

			currentKurs = currentEntry["name"];
			//pruefe, ob ein kurs mit dem aktuellen namen bereits eine id in der db hat
			if ((await pool.query(`SELECT COUNT(id) FROM kurs WHERE kursname='${currentKurs}';`)).rows[0].count == 0) {
				//existiert keine id fuer den entsprechenden namen, wird ein neuer eintrag hinzugefuegt
				await pool.query(`INSERT INTO kurs (kursname, kurskuerzel) VALUES ('${currentKurs}', '${currentKurs.substring(0, 3)}');`);
			}
			//die id des zuvor, oder nun existierende eintrags mit dem aktuellen namen wird aus der db geholt
			currentKursId = (await pool.query(`SELECT id FROM kurs WHERE kursname='${currentKurs}';`)).rows[0].id;
			
			let terminart = currentEntry["terminart"];
			let wochentag = currentEntry["wochentag"];
			let startzeit = currentEntry["startzeit"];
			let dauer = currentEntry["dauer"];
			let raum = currentEntry["raum"];

			//existiert keine id fuer die kombination aus kurs, doz, wochentag und startzeit, wird ein neuer eintrag hinzugefuegt
			if ((await pool.query(`SELECT COUNT(id) FROM termin WHERE kursid='${currentKursId}' AND dozid='${currentDozId}' AND wochentag='${wochentag}' AND startzeit='${startzeit}';`)).rows[0].count == 0) {
				await pool.query(`INSERT INTO termin (kursid, dozid, terminart, wochentag, startzeit, dauer, raum) VALUES ('${currentKursId}','${currentDozId}','${terminart}', '${wochentag}', '${startzeit}', '${dauer}', '${raum}');`);
			}
			
			//existiert keine id fuer die kombination aus studiengang und kurs, wird ein neuer eintrag mit dem aktuellen semester hinzugefuegt
			if ((await pool.query(`SELECT COUNT(studiengangid) FROM studiengang_kurs WHERE studiengangid='${currentStudyId}' AND kursid='${currentKursId}';`)).rows[0].count == 0) {
				await pool.query(`INSERT INTO studiengang_kurs (studiengangid, kursid, semester) VALUES ('${currentStudyId}','${currentKursId}','${currentSemester}');`);
			}
		}
	}
	return "Datenbank befuellt";
}

function readJsonFile(filePath) {
	const data = fs.readFileSync(filePath, "utf8");
	const jsonData = JSON.parse(data);
	return jsonData;
}
