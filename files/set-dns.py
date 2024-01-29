import requests
import json
import pprint


# curl -X GET -H 'Content-Type: application/json' -H 'Authorization: Bearer $apiKey' "https://api.1cloud.ru/Dns"

url = "https://api.1cloud.ru/Dns"
# payload = open("request.json")
headers = {
    "content-type": "application/json",
    "Authorization": "Bearer $apiKey",
}
# r = requests.post(url, data=payload, headers=headers)

r = requests.get(url=url, headers=headers)
json_object = json.loads(r.text)

# pprint.pprint(r.text, compact=True)
print(json.dumps(json_object, indent=2))
# print(rtext)

# r.json()
