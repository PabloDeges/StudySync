const fs = require("fs");
const pool = require("../model/db");

require("dotenv").config();

async function putJsonDataInDb() {
	await selectSchema();
	let data = readJsonFile("./stundenplaene.json")["stundenplaene"];
	let currentStudyName, currentStudyType, currentSemester;
	let currentKurs, currentKursInfos, currentDoz, currentDozMail;
	let currentStudyId, currentKursId, currentDozId, currentSemesterId;
    let currentWeek, currentEntry;
	let kursVorherVorhanden, kurseDesSemesters;
	const BACHELOR = "Bachelor";
	const MASTER = "Master";

	for (let i = 0; i < data.length; i++) {
		kurseDesSemesters = new Set();
		//name des aktuellen studiengangs wird von allen weiteren zahlen befreit und die semesterbezeichnung wird entfertnt
		currentStudyName = data[i]["studiengang"].split(".")[0].replace(/[0-9]/, "");
		currentStudyName = currentStudyName.replace("Wintersemester", "").replace("Sommersemester", "");
		//ist im namen des studiengangs festgelegt, um was fuer eine art an studiengang es sich haelt, wird dies gesondert gespeichert
		if (currentStudyName.includes(MASTER)){
			currentStudyType = MASTER;
			currentStudyName = currentStudyName.replace(MASTER, "").trim();
		} else {
			currentStudyType = BACHELOR;
			currentStudyName = currentStudyName.replace(BACHELOR, "").trim();
		}
		currentStudyId = await studiengangSchreiben(currentStudyName, currentStudyType);	

		currentSemester = data[i]["kuerzel"];
		currentSemesterId = await semesterSchreiben(currentSemester);
		
		currentWeek = data[i]["stundenplan"];

		for (let j = 0; j < currentWeek.length; j++) {
			currentEntry = currentWeek[j];

			currentDoz = currentEntry["dozent"];
			currentDozMail = currentEntry["email"];
			currentDozId = await dozSchreiben(currentDoz, currentDozMail);

			currentKurs = currentEntry["name"];
			currentKursInfos = await kursSchreiben(currentKurs, currentKurs.substring(0, 3));
			currentKursId = currentKursInfos[0];
			kursVorherVorhanden = currentKursInfos[1];

			let terminart = currentEntry["terminart"];
			let wochentag = currentEntry["wochentag"];
			let startzeit = currentEntry["startzeit"];
			let dauer = currentEntry["dauer"];
			let raum = currentEntry["raum"];

			//existiert keine id fuer die kombination aus kurs, doz, wochentag und startzeit, wird ein neuer eintrag hinzugefuegt
			if ((await pool.query(`SELECT COUNT(id) FROM termin WHERE kursid='${currentKursId}' AND dozid='${currentDozId}' AND wochentag='${wochentag}' AND startzeit='${startzeit}';`)).rows[0].count == 0) {
				if (kursVorherVorhanden && !kurseDesSemesters.has(currentKursId)) {
					currentKursId = (await kursSchreiben(currentKurs + " - " + currentSemester, currentKurs.substring(0, 3)))[0];
				}
				await pool.query(`INSERT INTO termin (kursid, dozid, terminart, wochentag, startzeit, dauer, raum) VALUES ('${currentKursId}','${currentDozId}','${terminart}', '${wochentag}', '${startzeit}', '${dauer}', '${raum}');`);
			}
			
			//existiert keine id fuer die kombination aus studiengang und kurs, wird ein neuer eintrag mit dem aktuellen semester hinzugefuegt
			if ((await pool.query(`SELECT COUNT(studiengangid) FROM studiengang_kurs WHERE studiengangid='${currentStudyId}' AND kursid='${currentKursId}';`)).rows[0].count == 0) {
				await pool.query(`INSERT INTO studiengang_kurs (studiengangid, kursid, semesterid) VALUES ('${currentStudyId}','${currentKursId}','${currentSemesterId}');`);
			}
			kurseDesSemesters.add(currentKursId);
		}
	}
	return "Datenbank befuellt";
}

const changeToSchema = async(req, res, next) => {
	await selectSchema();
	next();
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

async function studiengangSchreiben(studyName, studyType) {
	//pruefe, ob ein studiengang mit dem aktuellen namen bereits eine id in der db hat
	if ((await pool.query(`SELECT COUNT(id) FROM studiengang WHERE studiengangname='${studyName}' AND studiengangart='${studyType}';`)).rows[0].count == 0) {
		//existiert keine id fuer den entsprechenden namen, wird ein neuer eintrag hinzugefuegt
		await pool.query(`INSERT INTO studiengang (studiengangname, studiengangart) VALUES ('${studyName}','${studyType}');`);
	}
	//die id des zuvor, oder nun existierende eintrags mit dem aktuellen namen wird aus der db geholt
	return (await pool.query(`SELECT id FROM studiengang WHERE studiengangname='${studyName}' AND studiengangart='${studyType}';`)).rows[0].id;
}

async function semesterSchreiben(semester) {
	//pruefe, ob ein semester mit der aktuellen kennung bereits eine id in der db hat
	if ((await pool.query(`SELECT COUNT(id) FROM semester WHERE semesterkennung='${semester}';`)).rows[0].count == 0) {
		//existiert keine id fuer die entsprechende kennug, wird ein neuer eintrag hinzugefuegt
		await pool.query(`INSERT INTO semester (semesterkennung) VALUES ('${semester}');`);
	}
	//die id des zuvor, oder nun existierende eintrags mit dem aktuellen namen wird aus der db geholt
	return (await pool.query(`SELECT id FROM semester WHERE semesterkennung='${semester}';`)).rows[0].id;
}

async function dozSchreiben(doz, dozMail) {
	//pruefe, ob ein dozent mit dem aktuellen namen bereits eine id in der db hat
	if ((await pool.query(`SELECT COUNT(id) FROM doz WHERE dozname='${doz}';`)).rows[0].count == 0) {
		//existiert keine id fuer den entsprechenden namen, wird ein neuer eintrag hinzugefuegt
		await pool.query(`INSERT INTO doz (dozname, dozkuerzel, dozmail) VALUES ('${doz}', '${doz.substring(0, 3)}', '${dozMail}');`);
	}
	//die id des zuvor, oder nun existierende eintrags mit dem aktuellen namen wird aus der db geholt
	return (await pool.query(`SELECT id FROM doz WHERE dozname='${doz}';`)).rows[0].id;
}

async function kursSchreiben(kurs, kursKuerzel) {
	let kursVorherVorhanden = true;
	//pruefe, ob ein kurs mit dem aktuellen namen bereits eine id in der db hat
	if ((await pool.query(`SELECT COUNT(id) FROM kurs WHERE kursname='${kurs}';`)).rows[0].count == 0) {
		//existiert keine id fuer den entsprechenden namen, wird ein neuer eintrag hinzugefuegt
		await pool.query(`INSERT INTO kurs (kursname, kurskuerzel) VALUES ('${kurs}', '${kursKuerzel}');`);
		kursVorherVorhanden = false;
	}
	//die id des zuvor, oder nun existierende eintrags mit dem aktuellen namen wird aus der db geholt
	return [(await pool.query(`SELECT id FROM kurs WHERE kursname='${kurs}';`)).rows[0].id, kursVorherVorhanden];
}

async function selectSchema() {
	const schema = process.env.DBSCHEMA;
    if((await pool.query(`SELECT schema_name FROM information_schema.schemata WHERE schema_name = '${schema}'`)).rowCount == 1) {
        await pool.query("SET Search_Path TO " + schema)
            .then(() => "Schema \"" + schema + "\" eingestellt")
            .catch(() => "Fehler beim einstellen des Schemas \"" + schema + "\"");
    }
}