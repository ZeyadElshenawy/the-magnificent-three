from flask import Flask, request, jsonify
from joblib import load
import numpy as np
import os
from PIL import Image
import io

app = Flask(__name__)

# Load all models
model_path = os.path.join(os.path.dirname(__file__), 'Models/classification')
models = {
    'decision_tree': load(os.path.join(model_path, 'dt_model.pkl')),
    'logistic_regression': load(os.path.join(model_path, 'logreg_model.pkl')),
    'random_forest': load(os.path.join(model_path, 'rf_model.pkl')),
    'svc': load(os.path.join(model_path, 'svc_model.pkl'))
}

# Function to preprocess image
def preprocess_image(image_bytes):
    image = Image.open(io.BytesIO(image_bytes)).convert('L')  
    image = image.resize((64, 64))  
    image_array = np.array(image).reshape(1, -1) / 255.0  
    return image_array

@app.route('/classify', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400

    # Get the selected model from the request
    model_name = request.form.get('model', 'svc')  # Default to SVC if not specified
    if model_name not in models:
        return jsonify({'error': f'Invalid model name. Available models: {list(models.keys())}'}), 400

    image_file = request.files['image']
    image_bytes = image_file.read()

    try:
        features = preprocess_image(image_bytes)
        model = models[model_name]
        prediction = model.predict(features)
        
        # Define class names mapping
        CLASS_NAMES = {
            0: 'Meningioma',
            1: 'Glioma',
            2: 'Pituitary Tumor'
        }
        
        # Get probability scores if the model supports it
        if hasattr(model, 'predict_proba'):
            probabilities = model.predict_proba(features)
            confidence = float(probabilities[0].max())
        else:
            # If model doesn't support probabilities, use a default confidence
            confidence = 1.0
        
        class_index = int(prediction[0])
        class_name = CLASS_NAMES.get(class_index, 'Unknown')
            
        return jsonify({
            'class': str(class_index),
            'class_name': class_name,
            'confidence': confidence,
            'model_used': model_name
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/available_models', methods=['GET'])
def get_available_models():
    return jsonify({
        'models': list(models.keys())
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get("PORT", 5000)))
