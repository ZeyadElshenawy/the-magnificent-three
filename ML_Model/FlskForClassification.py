from flask import Flask, request, jsonify
from joblib import load
import numpy as np
import os
from PIL import Image
import io

app = Flask(__name__)

# تحميل النموذج
model_path = os.path.join(os.path.dirname(__file__), 'Models/classification')
model = load(os.path.join(model_path, 'random_forest.joblib'))

# دالة لتحويل الصورة إلى مصفوفة مناسبة للنموذج
def preprocess_image(image_bytes):
    image = Image.open(io.BytesIO(image_bytes)).convert('L')  # تحويل إلى رمادي لو النموذج يتوقع كده
    image = image.resize((64, 64))  
    image_array = np.array(image).reshape(1, -1) / 255.0  
    return image_array

@app.route('/classify', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400

    image_file = request.files['image']
    image_bytes = image_file.read()

    try:
        features = preprocess_image(image_bytes)
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
            'confidence': confidence
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get("PORT", 5000)))
