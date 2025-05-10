import requests

data = {
    "features": [2, 120, 70, 20, 79, 25.5, 0.5, 33]
}

res = requests.post("http://127.0.0.1:5000/predict", json=data)
print(res.json())
