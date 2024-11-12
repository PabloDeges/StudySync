import requests
from bs4 import BeautifulSoup
import json

# URL der Seite
url = "https://www.hochschule-bochum.de/personen/"

# Anfrage senden, um die HTML-Seite zu erhalten
response = requests.get(url)
if response.status_code != 200:
    print("Fehler beim Abrufen der Seite:", response.status_code)
    exit()

# BeautifulSoup-Objekt zum Parsen des HTML-Inhalts
soup = BeautifulSoup(response.text, "html.parser")

# Liste zum Speichern der Personendaten
personen_liste = []

# Suche nach den HTML-Elementen, die die Informationen zu den Personen enthalten
# (dieser Teil hängt von der Struktur der Webseite ab und muss ggf. angepasst werden)
for person in soup.select("div.person-list__item"):  # Beispielselektor, passt den Selektor an die Struktur der Webseite an
    # Namen und Kontaktdaten extrahieren
    name = person.select_one("div.person-list__item-title").get_text(strip=True).replace("\n", "").replace("\t","") if person.select_one("div.person-list__item-title") else "Unbekannt"
    #email = person.select_one("div.person-list__item-email").get("href", "").replace("mailto:", "") if person.select_one("div.person-list__item-email") else "Keine E-Mail"
    email = person.select_one("div.person-list__item-email").get_text(strip=True).replace("(at)", "@").replace("<wbr/>", "") if person.select_one("div.person-list__item-email") else "Keine E-Mail"
    #email = person.select_one("div.person-list__item-email").get("href", "")
    
    # Daten in ein Wörterbuch speichern
    person_info = {
        "name": name,
        "email": email,
    }
    
    # Person zur Liste hinzufügen
    personen_liste.append(person_info)

# Daten als JSON-Datei speichern
with open("personenverzeichnis.json", "w", encoding="utf-8") as json_file:
    json.dump(personen_liste, json_file, ensure_ascii=False, indent=4)

print("Daten wurden erfolgreich in 'personenverzeichnis.json' gespeichert.")