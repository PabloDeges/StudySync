#die HTML Dateien muessten als Liste heruntergeladen werden - Druckversion -> Nein
#Der Name des Studiengangs muss als 1. Uebergabeparameter des Programms uebergeben werden - Nichtmehr Aktuell
#Der Studiengang muss im Dictionary GetStundenplan als Semestergroup uebergeben werden
#Damit das Tool genutzt werden kann, muesen die Variablen im Dictionary Data ausgefuellt werden
#!!!! Bisher nicht zertifizierte HTTPs Requests
from tkinter import *
from tkinter import ttk
from CTkTable import *
import customtkinter
from sys import argv
import requests
import ssl

urllink = 'https://wwwccb.hochschule-bochum.de/campusInfo/newslist/displayTimetable.php'
loginUrl = 'https://wwwccb.hochschule-bochum.de/campusInfo/index.php'

data = {
    'username': 'DeinNutzerName',
    'loginPassword': 'DeinPasswort'
}

getStundenplan = {
    'lecturer_nr' : '%',
    'room_nr' : '%',
    'day_nr' : '%',
    'time_nr' : '%',
    'lm' : "l",
    'print' : '0',
    'semestergroup_nr' : '254',
    'sendForm:' : 'Anzeigen'

}

def fetchSemesterGroups(S):
    pass

def remove(string):
    string = string.replace("\t","")
    #string = string.replace("\n","")
    string = string.replace("\r","")
    string = string.replace(" ","")
    string = string.replace("<td>","")
    string = string.replace("</td>","")
    return string;

def init(html, modules):
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
    #root.geometry('600x600')

def show(cell):
    label.configure(text=cell["value"].toJSON())


class Subject:
    def __init__(self,name,teacher,time,days,room):
        self.name,self.teacher, self.time, self.days, self.room = name, teacher, time, days, room;
    def __str__(self):
        #return f'{self.name} {self.teacher} {self.time}'
        return f'{self.name}\n {self.teacher}'
    __repr__ = __str__
    def toJSON(self):
        return f'{{\n"name": "{self.name}" \n"lehrender": "{self.teacher}"\n"tag": "{self.days}"\n"time": "{self.time}"\n"room": "{self.room}"\n}}'
    

modules = [['Montag'],['Dienstag'],['Mittwoch'],['Donnerstag'],['Freitag']]

def scrape(html, modules):
    html = remove(html)
    #print(html)
    htmlSplit = html.rsplit("\n")
    #print(htmlSplit)
    for line in range(len(htmlSplit)):
        #print(htmlSplit[line].find("<trheight='25'class='tableRowGrey1'>"))
        if htmlSplit[line].find("<trheight='25'class='tableRowGrey1'>")==0 or htmlSplit[line].find("<trheight='25'class='tableRowGrey0'>")==0:
            for module in modules:
                if module.count(htmlSplit[line+3]) == 1:
                    module.append(Subject(htmlSplit[line+2],htmlSplit[line+1],htmlSplit[line+4],htmlSplit[line+3],htmlSplit[line+5]))
    #print(modules)
    return modules




def login():
    with requests.session() as s:
        response = s.post(loginUrl, data,verify=ssl.CERT_NONE) #Achtung. Unverifizierte Https Anfrage. Unbedingt Loesung finden
        stundenplan = s.post(urllink,getStundenplan,verify=ssl.CERT_NONE) #Achtung. Unverifizierte Https Anfrage. Unbedingt Loesung finden
        #print(stundenplan.text)
        return stundenplan.text

init(login(),modules)
