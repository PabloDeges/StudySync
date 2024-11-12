import fitz  # PyMuPDF

# PDF öffnen
pdf_document = fitz.open(r"utils\PO_2019_Modulhandbuch_Bachelor_Informatik_Stand_Dez_2020.pdf")

# Liste zur Speicherung des extrahierten Textes
extracted_text = []

# Text extrahieren
for page_num in range(pdf_document.page_count):
    page = pdf_document[page_num]
    text = page.get_text("text")
    extracted_text.append(f"Seite {page_num}:\n{text}\n")
    print(f"Seite {page_num + 1}:\n{text}\n")

full_text = "\n".join(extracted_text)

with open("ausgabe_text.txt", "w", encoding="utf-8") as file:
    file.write(full_text)
    
pdf_document.close()