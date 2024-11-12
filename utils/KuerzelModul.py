import re


# Datei öffnen und den Inhalt einlesen
with open("ausgabe_text.txt", "r", encoding="utf-8") as file:
    text = file.read()


# Regex-Pattern zum Erfassen des Modulnamens und des Kürzels im Format "Modulname (Kürzel)"
pattern = r'([A-Za-zäöüÄÖÜß0-9*\s]+)\s\((IB[A-Z0-9\s-]+)\)'

# Finde alle Übereinstimmungen
matches = re.findall(pattern, text)

# Die Ergebnisse drucken
for match in matches:
    modul_name, kuerzel = match
    print(f"Modulname: {modul_name.strip()}, Kürzel: {kuerzel}")