#die HTML Dateien muessten als Liste heruntergeladen werden - Druckversion -> Nein
#Damit das Tool genutzt werden kann, muesen die Variablen im Dictionary Data ausgefuellt werden
#!!!! Bisher nicht zertifizierte HTTPs Requests
from sys import argv
import requests
import json
import requests
from bs4 import BeautifulSoup
import json
import re
import getpass

email_datei_name = 'personenverzeichnis.json'




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
    'username': getpass.getpass('Gebe deinen Benutzernamen ein'),
    'loginPassword': getpass.getpass('Gebe dein Passwort ein')
}
def switchCharset(string): #Umlaute laden
    string = string.replace("Ü","Ue")
    string = string.replace("ü","ue")
    string = string.replace("ö","oe")
    string = string.replace("ä","ae")
    string = string.replace("Ö","Ue")
    string = string.replace("Ä","ae")
    return string
def loadEMails():
    with open(email_datei_name, 'r') as file:
        email_list = json.load(file)
    return email_list

def fetchSemesterGroups(session): #Alle Semester laden
    request = session.get(urllink,verify=False)
    
    semesterGroups = []
    semesterGroups = scrapeSelectionPage(BeautifulSoup(request.text,"html.parser"), "semestergroup_nr")
    return semesterGroups
    
def scrapeSelectionPage(html,filter): #Auswahlseite Scrapen
    studiengaenge = []
    pattern = r'<option value="(\d+)">([A-Za-z0-9_]+(?:[A-Za-z0-9]*))\s*[-|]?\s*([^<]*?(\d+\.?\d*)\s*\.?\s*(Semester|Wintersemester|Gr\.[A-B]))'

    for element in html.find_all("option"):
        matches = re.findall(pattern, str(element))
        for id, kuerzel, studiengang, ignoreee, ignore in matches:
            studiengaenge.append({'id':id,'studiengang':studiengang,'kuerzel':kuerzel})
        
    return studiengaenge
            
def scrape(html,semester,kuerzel): #WebStundenplan Scrapen - Muss immer in Kombination mit fetchStundenplan genutzt werden
    soup = BeautifulSoup(html.text, "html.parser")
    semester_info = []
    stundenplan = {
            'studiengang': semester,
            'kuerzel': kuerzel
    }
    for modul in soup.select("tr"):
        data_list = [] #0 lehrer, 1 name, 2 tag, 3 zeit, 4 raum
        emailList = loadEMails()
        for data in modul.select("td"):
            try:
                data_list.append(data.get_text(strip=True))
            except TypeError:
                print("Fehler, keine Data")
        if len(data_list) > 2:
            semester_info.append(to_dict(emailList,data_list[0],data_list[1],data_list[2],data_list[3],data_list[4]))
    stundenplan.update({'stundenplan': semester_info})
    #print(stundenplan)
    return stundenplan


def startSession(): # Nur einmal nutzen  -- Gueltige Session generieren
    session = requests.session()
    session.post(loginUrl, 
                 data,verify=False)
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
                            headers=header,verify=False)
    return stundenplan 
def writeIntoJSON(semesterList): #Stundenplan in JSON schreiben
    with open('stundenplaene.json', 'w', encoding="utf-8") as outfile:
        json.dump(semesterList, outfile, ensure_ascii=True, indent=4)
        print("Die Stundenplaene wurden erfolgreich gespeichert")
def to_dict(emailList,dozent,name,wochentag,startzeit,raum,terminart='pass',):
    name, terminart = extractTerminart(name)
    return {
        "dauer": 60,
        "dozent": switchCharset(dozent),
        "name": switchCharset(name),
        "raum": raum,
        "startzeit": startzeit[0:startzeit.find('-')],
        "terminart": switchCharset(terminart)[0],
        "wochentag": wochentag,
        'email': get_email_for_dozent(dozent,emailList)
    }

def getAllStundenplaene(clientSession):
    semesterList = fetchSemesterGroups(clientSession)
    stundenplan = []
    for studiengang in semesterList:
        studiengang_info = [value for value in studiengang.values()]
        print(f'Das Semester {studiengang_info[1]} wird nun gespeichert')
        stundenplan.append(scrape(fetchStundenplan(clientSession,studiengang_info[0]),studiengang_info[1],studiengang_info[2]))
            
    semesterList = {'stundenplaene': stundenplan}
    return semesterList
def get_email_for_dozent(dozent,email_list):
# Nach der E-Mail anhand des Nachnamens suchen
    for entry in email_list:
    # E-Mail-Adresse extrahieren
        email = entry["email"]
        #print(email)
    # Den Nachnamen aus der E-Mail extrahieren (Teil nach dem ersten Punkt)
        last_name = email.split('@')[0].split('.')[-1].lower()
        last_name = last_name.replace(" ","")
        #print("dozent lower:",dozent.lower().replace(" ",""))
        #print("last name:",last_name)
        if dozent.lower().replace(" ","") == last_name:
            return email
    return "E-Mail nicht gefunden"
def extractTerminart(name):
    if name[-2] == '-' or name[-2] == " ": return name[0:-2], name[-1]
    elif name[1]=='-': return name[2:],name[0]
    elif name.find('Tutorium') != -1: return name[0:name.find('Tutorium')-1],'T'
    else: return name, 'N/A';

def main():
    requests.packages.urllib3.disable_warnings() 
    global clientSession
    clientSession = startSession()
    writeIntoJSON(getAllStundenplaene(clientSession))
if __name__ == '__main__':
    main()