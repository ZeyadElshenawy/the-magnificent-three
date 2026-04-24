from flask import Flask, request, jsonify
from joblib import load
import numpy as np
import os

app = Flask(__name__)

# Use relative paths
model_path = os.path.join(os.path.dirname(__file__), 'Models/Regression')

svm_model = load(os.path.join(model_path, 'svm_model.joblib'))
scaler = load(os.path.join(model_path, 'scaler.joblib'))


@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    features = np.array([data.get('features')])
    scaled_data = scaler.transform(features)
    prediction = svm_model.predict(scaled_data)
    return jsonify({'prediction': int(prediction[0])})

if __name__ == '__main__':
    # Make it work on Railway
    app.run(host='0.0.0.0', port=int(os.environ.get("PORT", 5001)))
