from tkinter import *
from tkinter import ttk
from CTkTable import *
import customtkinter
from sys import argv

def remove(string):
    string = string.replace("\t","")
    string = string.replace("\n","")
    string = string.replace("\r","")
    string = string.replace(" ","")
    string = string.replace("<td>","")
    string = string.replace("</td>","")
    return string;

def init(modules):
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
    label.configure(text=cell["value"].printFull())


class Subject:
    def __init__(self,name,teacher,time,days,room):
        self.name,self.teacher, self.time, self.days, self.room = name, teacher, time, days, room;
    def __str__(self):
        #return f'{self.name} {self.teacher} {self.time}'
        return f'{self.name}\n {self.teacher}'
    __repr__ = __str__
    def printFull(self):
        return f'{{\n"name": "{self.name}" \n"lehrender": "{self.teacher}"\n"tag": "{self.days}"\n"time": "{self.time}"\n"room": "{self.room}"\n}}'
    

modules = [['Montag'],['Dienstag'],['Mittwoch'],['Donnerstag'],['Freitag']]
html = open(f'Websites/{argv[1]}.html')
#print(modules.count('Montag'))
#for x in modules:
#    print(x.count("Montag"))

for line in html:
    line = remove(line)
    print(line)
    if line.find('<trheight="25"class="tableRowGrey1">') == 0 or line.find('<trheight="25"class="tableRowGrey0">') == 0:
        lines = []
        for i in range(5):
            lines.append(remove(html.readline()))
        for module in modules:
            if module.count(lines[2]) == 1:
                module.append(Subject(lines[1],lines[0],lines[3],lines[2],lines[4]))

#for x in modules:
    #print(x)

init(modules)