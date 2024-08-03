#die HTML Dateien muessten als Liste heruntergeladen werden - Druckversion -> Nein
#Damit das Tool genutzt werden kann, muesen die Variablen im Dictionary Data ausgefuellt werden
#!!!! Bisher nicht zertifizierte HTTPs Requests
from tkinter import *
from tkinter import ttk
from CTkTable import *
from CTkListbox import *
import customtkinter
from sys import argv
import requests
import ssl

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
    'username': 'YourUserName',
    'loginPassword': 'YourPassword'
}


def fetchSemesterGroups(session): #Alle Semester laden
    request = session.get(urllink,verify=ssl.CERT_NONE)
    #print(request.content)
    #print(type(request.content))
    semesterGroups = []
    semesterGroups = scrapeSelectionPage(request.content.decode("ISO8859-15"), semesterGroups, "semestergroup_nr")
    initGUISemester(semesterGroups)

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

def initGUISemester(semesterGroups): #Alle Semester als Liste anzeigen
    root = customtkinter.CTk()
    listbox = CTkListbox(root, command=listBoxEvent)

    listbox.pack(fill="both", expand=True, padx=10, pady=10)

    for i in range(0,len(semesterGroups)):
        listbox.insert(i,semesterGroups[i])
    root.geometry('600x600')
    root.mainloop()

def listBoxEvent(selected_option): #eventlistener
    initGUI(fetchStundenplan(clientSession,selected_option.getID()), initStundenplan())

def initGUI(html, modules): #Stundenplan Gui
    modules = scrape(html, modules)
    root = customtkinter.CTk()
    customtkinter.set_appearance_mode("dark")  # Modes: system (default), light, dark
    customtkinter.set_default_color_theme("blue")  # Themes: blue (default), dark-blue, green
    table = CTkTable(master=root, row=5, column=10, values=modules, command=show)
    table.pack(expand=True, fill="both", padx=20, pady=20)

    global frame, label;
    frame = customtkinter.CTkFrame(root)
    label = customtkinter.CTkLabel(frame,anchor=E,text="",justify=LEFT,font=("Arial",25))
    label.place(relx=0.0, rely=0)
    frame.pack(expand=True, fill="both")
    root.mainloop()
    

def show(cell):
    label.configure(text=cell["value"].toJSON())

class Subject: #Klasse fuer Module
    def __init__(self,name,teacher,time,days,room):
        self.name,self.teacher, self.time, self.days, self.room = name, teacher, time, days, room;
    def __str__(self):
        #return f'{self.name} {self.teacher} {self.time}'
        return f'{self.name}\n {self.teacher}'
    __repr__ = __str__
    def toJSON(self):
        return f'{{\n"name": "{self.name}" \n"lehrender": "{self.teacher}"\n"tag": "{self.days}"\n"time": "{self.time}"\n"room": "{self.room}"\n}}'

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
            
def scrape(html, modules): #WebStundenplan Scrapen
    html = removeHTML(html)
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


def startSession(): # Only use Once please ##Gueltige Session generieren
    session = requests.session()
    session.post(loginUrl, data,verify=ssl.CERT_NONE) #Achtung. Unverifizierte Https Anfrage. Unbedingt Loesung findenrred: OSErrorCould not find a suitable TLS CA certificate bundle, invalid path
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
    stundenplan = session.post(urllink,getStundenplan,headers=header,verify=ssl.CERT_NONE) #Achtung. Unverifizierte Https Anfrage. Unbedingt Loesung finden
    stundenplanLatin = switchCharset(stundenplan.content.decode("ISO8859-15"))
    return stundenplanLatin

def main():
    global clientSession
    clientSession = startSession()

    fetchSemesterGroups(clientSession)

if __name__ == '__main__':
    main()
