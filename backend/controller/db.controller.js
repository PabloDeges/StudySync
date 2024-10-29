const fs = require("fs");
const pool = require("../model/db");

require("dotenv").config();

async function putJsonDataInDb() {
	let data = readJsonFile("./stundenplaene.json")["stundenplaene"];
	let currentStudy, currentStudyName, currentStudyType, currentSemester;
	let currentKurs, currentDoz;
	let currentStudyId, currentKursId, currentDozId, currentSemesterId;
    let currentWeek, currentEntry;
	const BACHELOR = "Bachelor";
	const MASTER = "Master";

	for (let i = 0; i < data.length; i++) {
		//der name des aktuellen studiengangs wird von seinem kuerzel getrennt und sonderzeichen werden entfernt
		currentStudy = data[i]["studiengang"].split("-");
		//name des aktuellen studiengangs wird von allen weiteren zahlen befreit und die semesterbezeichnung wird entfertnt
		currentStudyName = currentStudy[1].split(".")[0].replace(/[0-9]/, "");
		currentStudyName = currentStudyName.replace("Wintersemester", "").replace("Sommersemester", "");
		//ist im namen des studiengangs festgelegt, um was fuer eine art an studiengang es sich haelt, wird dies gesondert gespeichert
		if (currentStudyName.includes(MASTER)){
			currentStudyType = MASTER;
			currentStudyName = currentStudyName.replace(MASTER, "");
		} else {
			currentStudyType = BACHELOR;
			currentStudyName = currentStudyName.replace(BACHELOR, "");
		}

		//pruefe, ob ein studiengang mit dem aktuellen namen bereits eine id in der db hat
		if ((await pool.query(`SELECT COUNT(id) FROM studiengang WHERE studiengangname='${currentStudyName}' AND studiengangart='${currentStudyType}';`)).rows[0].count == 0) {
			//existiert keine id fuer den entsprechenden namen, wird ein neuer eintrag hinzugefuegt
			await pool.query(`INSERT INTO studiengang (studiengangname, studiengangart) VALUES ('${currentStudyName}','${currentStudyType}');`);
		}
		//die id des zuvor, oder nun existierende eintrags mit dem aktuellen namen wird aus der db geholt
		currentStudyId = (await pool.query(`SELECT id FROM studiengang WHERE studiengangname='${currentStudyName}' AND studiengangart='${currentStudyType}';`)).rows[0].id;
		

		currentSemester = currentStudy[0];

		//pruefe, ob ein semester mit der aktuellen kennung bereits eine id in der db hat
		if ((await pool.query(`SELECT COUNT(id) FROM semester WHERE semesterkennung='${currentSemester}';`)).rows[0].count == 0) {
			//existiert keine id fuer die entsprechende kennug, wird ein neuer eintrag hinzugefuegt
			await pool.query(`INSERT INTO semester (semesterkennung) VALUES ('${currentSemester}');`);
		}
		//die id des zuvor, oder nun existierende eintrags mit dem aktuellen namen wird aus der db geholt
		currentSemesterId = (await pool.query(`SELECT id FROM semester WHERE semesterkennung='${currentSemester}';`)).rows[0].id;
		
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
				await pool.query(`INSERT INTO studiengang_kurs (studiengangid, kursid, semesterid) VALUES ('${currentStudyId}','${currentKursId}','${currentSemesterId}');`);
			}
		}
	}
	return "Datenbank befuellt";
}

async function changeToSchema() {
	const schema = process.env.DBSCHEMA;
    if((await pool.query(`SELECT schema_name FROM information_schema.schemata WHERE schema_name = '${schema}'`)).rowCount == 1) {
        return pool.query("SET Search_Path TO " + schema)
            .then(() => "Schema \"" + schema + "\" eingestellt")
            .catch(() => "Fehler beim einstellen des Schemas \"" + schema + "\"");
    }
    return "Schema \"" + schema + "\" nicht gefunden";
}

module.exports = {
	putJsonDataInDb,
	changeToSchema
};

function readJsonFile(filePath) {
	const data = fs.readFileSync(filePath, "utf8");
	const jsonData = JSON.parse(data);
	return jsonData;
}