#die HTML Dateien muessten als Liste heruntergeladen werden - Druckversion -> Nein
#Damit das Tool genutzt werden kann, muesen die Variablen im Dictionary Data ausgefuellt werden
#!!!! Bisher nicht zertifizierte HTTPs Requests
from sys import argv
import requests
import ssl
import pandas as pd

urllink = 'https://wwwccb.hochschule-bochum.de/campusInfo/newslist/displayTimetable.php'
loginUrl = 'https://wwwccb.hochschule-bochum.de/campusInfo/index.php'
cert_path = 'utils/zertifikate/certi.pem'

header = {
'Host': 'wwwccb.hochschule-bochum.de',
'User-Agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0",
'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8',
'Accept-Language': 'de,en-US;q=0.7,en;q=0.3',
'Accept-Encoding': 'gzip, deflate, zstd',
'Content-Type': 'application/x-www-form-urlencoded; charset=ISO8859-15',
}
data = {
    'username': 'YourName',
    'loginPassword': 'YourPasswort'
}


def fetchSemesterGroups(session): #Alle Semester laden
    request = session.get(urllink,verify=ssl.CERT_NONE)
    semesterGroups = []
    semesterGroups = scrapeSelectionPage(request.content.decode("ISO8859-15"),
                                          semesterGroups, "semestergroup_nr")
    return semesterGroups

def switchCharset(string): #Umlaute laden
    string = string.replace("&Uuml;","Ü")
    string = string.replace("&uuml;","ü")
    string = string.replace("&ouml;","ö")
    string = string.replace("&auml;","ä")
    string = string.replace("&Ouml;","Ö")
    string = string.replace("&Auml;","Ä")
    return string

def removeOptionTag(html): #Formatierung
    html = html.replace('<optionvalue=','')
    html = html.replace('</option>','')
    html = html.replace('>',';')
    html = html.replace('"',"")
    return html.split(';')

def removeHTML(string): #Formatierung
    string = string.replace("\t","")
    #string = string.replace("\n","")
    string = string.replace("\r","")
    string = string.replace(" ","")
    string = string.replace("<td>","")
    string = string.replace("</td>","")
    return string;

class Subject: #Klasse fuer Module
    def __init__(self,name,teacher,time,days,room):
        self.name,self.teacher, self.time, self.days, self.room = name, teacher, time, days, room;
        self.splitName()
    def __str__(self):
        #return f'{self.name} {self.teacher} {self.time}'
        return f'{self.name}\n {self.teacher}'
    __repr__ = __str__
    def toJSON(self):
        return f'{{\n"name": "{self.name}" \n"lehrender": "{self.teacher}"\n"tag": "{self.days}"\n"time": "{self.time}"\n"room": "{self.room}"\n}}'
    def toRealJSON(self):
        df = pd.DataFrame({'name': [self.name],'terminart':[self.terminart],'wochentag':[self.days],'startzeit':[self.time],'dauer':["60 Minuten"],'raum':[self.room]})
        return df.to_json(orient='records',force_ascii=False)
    
    def splitName(self):
        self.terminart = self.name[self.name.find('-')+1:len(self.name)]
        self.name = self.name[0:self.name.find('-')]

class Semester: #Klasse fuer Ids
    def __init__(self,id,name):
        self.id, self.name = id, name
    def getID(self):
        return self.id
    def __str__(self):
        return f'{self.id}\t {self.name}'
    __repr__ = __str__
    def toJSON(self):
        return f'{{\n"id": "{self.id}" \n"name": "{self.name}"\n}}'
    
def initStundenplan(): #Leeren Stundenplan anlegen
    modules = [['Montag'],['Dienstag'],['Mittwoch'],['Donnerstag'],['Freitag']]
    return modules

def scrapeSelectionPage(html, array,filter): #Auswahlseite Scrapen
    html= removeHTML(html)
    #print(html)
    htmlSplit = html.rsplit('\n')
    #print(htmlSplit)
    for line in range(len(htmlSplit)):
        if htmlSplit[line].find('<selectstyle="color:black"name="'+filter+'">') ==0:
            line = line+2
            while htmlSplit[line] != "</select>":
                semesterSplit = removeOptionTag(htmlSplit[line])
                array.append(Semester(semesterSplit[0],semesterSplit[1]))
                line = line+1
    return array
            
def scrape(html): #WebStundenplan Scrapen - Muss immer in Kombination mit fetchStundenplan genutzt werden
    html = removeHTML(html)
    modules = initStundenplan()
    #print(html)
    htmlSplit = html.rsplit("\n")
    #print(htmlSplit)
    for line in range(len(htmlSplit)):
        if htmlSplit[line].find("<trheight='25'class='tableRowGrey1'>")==0 or htmlSplit[line].find("<trheight='25'class='tableRowGrey0'>")==0:
            for module in modules:
                if module.count(htmlSplit[line+3]) == 1:
                    module.append(Subject(htmlSplit[line+2],htmlSplit[line+1],htmlSplit[line+4],htmlSplit[line+3],htmlSplit[line+5]))
    #print(modules)
    return modules


def startSession(): # Nur einmal nutzen  -- Gueltige Session generieren
    session = requests.session()
    session.post(loginUrl, 
                 data,verify=ssl.CERT_NONE)
    return session

def fetchStundenplan(session, semesterNR): #Stundenplan request vorbereiten und absenden
    getStundenplan = {
    'lecturer_nr' : '%',
    'room_nr' : '%',
    'day_nr' : '%',
    'time_nr' : '%',
    'lm' : "l",
    'print' : '0',
    'semestergroup_nr' : semesterNR,
    'sendForm:' : 'Anzeigen'
    }
    stundenplan = session.post(urllink
                            ,getStundenplan,
                            headers=header,verify=ssl.CERT_NONE) 
    stundenplanLatin = switchCharset(
        stundenplan.content.decode("ISO8859-15"))
    return stundenplanLatin
def writeIntoJSON(module): #Stundenplan in JSON schreiben
    with open('stundenplan.json', 'w') as outfile:
        for stundenplan in module:
            for i in range(0,len(stundenplan)):
                for j in range(1,len(stundenplan[i])):
                    outfile.write(stundenplan[i][j].toRealJSON())
                    outfile.write("\n")

def getAllStundenplaene(clientSession):
    semesterList = fetchSemesterGroups(clientSession)
    stundenPlaeneList = []
    for studiengang in semesterList:
        stundenPlaeneList.append(scrape(fetchStundenplan(clientSession,studiengang.getID())))
    print(stundenPlaeneList)
    return stundenPlaeneList

def main():
    global clientSession
    clientSession = startSession()
    writeIntoJSON(getAllStundenplaene(clientSession))
    #print(getAllStundenplaene(clientSession))

    #Besorge Stundenplan
    #allSemesters = fetchSemesterGroups(clientSession)

    #modules = initStundenplan()
    #modules = scrape(fetchStundenplan(clientSession,248),modules)
    
    #Schreibe in JSOn
    #writeIntoJSON(modules)
    
    #To Do fuer morgen: Alle Semester IDs in eine Liste packen
    #Alle Stundenplaene abfragen - Check
    #Alles in Methoden auslagern - Check
if __name__ == '__main__':
    main()