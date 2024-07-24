

const getMainTimetable = async (req,res) => {
    try{
        res.status(200).json(data)
    }catch(error){
        res.status(500).json({ message: error.message });
    }
}

module.exports = {
    getMainTimetable
}

let data = {
    "timetable": {
      "Monday": [
        { "name": "MI1", "fullname": "Mathematik für Informatiker 1","room": "C0-07" },
        { "name": "MI1","fullname": "Mathematik für Informatiker 1", "room": "C0-07" },
        { "name": "ENG","fullname": "Englisch für Informatiker", "room": "C5-06" },
        { "name": "ENG","fullname": "Englisch für Informatiker", "room": "C5-06" },
        { "name": "", "fullname": "", "room": "" },
        { "name": "","fullname": "", "room": "" },
        { "name": "JP2","fullname": "Java Programmierung 2", "room": "C0-08" },
        { "name": "JP2","fullname": "Java Programmierung 2", "room": "C0-08" },
        { "name": "JP2","fullname": "Java Programmierung 2", "room": "C0-08" },
        { "name": "JP2","fullname": "Java Programmierung 2", "room": "C0-08" },
        { "name": "","fullname": "", "room": "" },
        { "name": "PY1","fullname": "Programmieren in Python 1", "room": "C6-08" },
        { "name": "PY1","fullname": "Programmieren in Python 1", "room": "C6-08" }
      ],
      "Tuesday": [
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "WT2", "room": "C6-07" },
        { "name": "WT2", "room": "C6-07" },
        { "name": "WT2", "room": "C6-07" },
        { "name": "", "room": "" },
        { "name": "JP1", "room": "C0-08" },
        { "name": "JP1", "room": "C0-08" },
        { "name": "", "room": "" },
        { "name": "", "room": "" }
      ],
      "Wednesday": [
        { "name": "RV", "room": "D3-13" },
        { "name": "RV", "room": "D3-13" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "SK1", "room": "D3-13" },
        { "name": "SK1", "room": "D3-13" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" }
      ],
      "Thursday": [
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "ENG", "room": "C5-06" },
        { "name": "ENG", "room": "C5-06" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "JP2", "room": "C0-08" },
        { "name": "JP2", "room": "C0-08" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "PY2", "room": "C5-08" },
        { "name": "PY2", "room": "C5-08" }
      ],
      "Friday": [
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" },
        { "name": "", "room": "" }
      ]
    }
  }