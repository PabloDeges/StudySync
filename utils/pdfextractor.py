import fitz  # PyMuPDF
from pdf2image import convert_from_path
import pytesseract

#Pfad zu Tesseract
pytesseract.pytesseract.tesseract_cmd = r"path"

# Pfad zur PDF-Datei
pdf_path = r"pdf path"

# Liste zur Speicherung des Textes
extracted_text = []

# Wandle PDF seiten in Bilder um
pages = convert_from_path(pdf_path, dpi=300, poppler_path=r"poppler bin path")

# Verarbeite jede Step by Step
for page_number, page_image in enumerate(pages, start=1):
    # Fuehre OCR auf Bildseite aus
    text = pytesseract.image_to_string(page_image, lang="eng")
    extracted_text.append(f"Seite {page_number}:\n{text}\n")
    
# Alle Seiten in einer einzigen Textdatei zusammenführen
full_text = "\n".join(extracted_text)

#den Text in einer Datei speichern
with open("ausgabe_text.txt", "w", encoding="utf-8") as file:
    file.write(full_text)

print("Textextraktion abgeschlossen.")
