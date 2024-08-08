import json

daten = {"data": "NEU"}

data = '{ "message": "Request tippi toppi", "status": "success"}'

z = json.loads(data)
z.update(daten)

print(json.dumps(z))
