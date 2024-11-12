import re
import json

# Liste, um die Module und Kuerzel zu speichern
modules_list = []

# Datei öffnen und den Inhalt einlesen
with open("ausgabe_text.txt", "r", encoding="utf-8") as file:
    text = file.read()


# Regex-Pattern zum Erfassen des Modulnamens und des Kuerzels im Format "Modulname (Kuerzel)"
pattern = r'(\n[A-Za-zäöüÄÖÜß0-9*\s]+)\s\W(IB[A-Z0-9\s-]+)\)'

# Finde alle Übereinstimmungen
matches = re.findall(pattern, text, re.MULTILINE)

# Die Ergebnisse drucken
for modul_name, kuerzel in matches:
    #print(modul_name.partition("\n")[0])#,end="ende")
    print(f"Modulname: {modul_name.strip()}, Kürzel: {kuerzel}")
    modules_list.append({"Modulname": modul_name.replace("\n","").replace("ii","ü"), "Kuerzel": kuerzel})


# Speichern der Liste als JSON Datei
with open("module_output.json", "w", encoding="utf-8") as json_file:
    json.dump(modules_list, json_file, ensure_ascii=False, indent=4)

print("Daten erfolgreich in 'module_output.json' gespeichert.")