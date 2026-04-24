import streamlit as st
import os
import numpy as np
import h5py
import cv2
import joblib
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split, learning_curve
from sklearn.metrics import accuracy_score, log_loss, classification_report, confusion_matrix
from sklearn.metrics import ConfusionMatrixDisplay

# Class label mapping
CLASS_NAMES = {0: 'Meningioma', 1: 'Glioma', 2: 'Pituitary Tumor'}

IMG_SIZE = 64
DATA_DIR = 'BrainTumorDataPublic_1-3064'
MODEL_DIR = 'Models\classification'

@st.cache_data
def load_data(data_dir=DATA_DIR, img_size=IMG_SIZE):
    X, y = [], []
    for fn in os.listdir(data_dir):
        if fn.endswith('.mat'):
            with h5py.File(os.path.join(data_dir, fn), 'r') as f:
                img = np.array(f['cjdata']['image']).T
                label = int(np.array(f['cjdata']['label'])[0][0]) - 1
                img = cv2.resize(img, (img_size, img_size)) / 255.0
                X.append(img)
                y.append(label)
    return np.array(X), np.array(y)

@st.cache_data
def split_data(X, y):
    X_flat = X.reshape(X.shape[0], -1)
    return train_test_split(X_flat, y, X, test_size=0.2,
                             random_state=42, stratify=y)

@st.cache_resource
def load_models(model_dir=MODEL_DIR):
    models = {
        'Logistic Regression': joblib.load(os.path.join(model_dir, 'logreg_model.pkl')),
        'SVC': joblib.load(os.path.join(model_dir, 'svc_model.pkl')),
        'Decision Tree': joblib.load(os.path.join(model_dir, 'dt_model.pkl')),
        'Random Forest': joblib.load(os.path.join(model_dir, 'rf_model.pkl')),
        'K-Nearest Neighbors': joblib.load(os.path.join(model_dir, 'knn_model.pkl')),
        'Naive Bayes': joblib.load(os.path.join(model_dir, 'nb_model.pkl'))
    }
    return models
def compute_learning_curves(estimator, X_train, y_train):
    """
    Compute learning curves (accuracy and log loss) on the training set using CV.
    """
    train_sizes, train_acc, test_acc = learning_curve(
        estimator, X_train, y_train,
        cv=5,
        scoring='accuracy',
        train_sizes=np.linspace(0.1, 1.0, 8),
        n_jobs=-1,
        shuffle=True,
        random_state=42
    )
    _, train_loss, test_loss = learning_curve(
        estimator, X_train, y_train,
        cv=5,
        scoring='neg_log_loss',
        train_sizes=train_sizes,
        n_jobs=-1,
        shuffle=True,
        random_state=42
    )
    return (
        train_sizes,
        train_acc.mean(axis=1),
        test_acc.mean(axis=1),
        -train_loss.mean(axis=1),
        -test_loss.mean(axis=1)
    )


# App layout
st.title('Brain Tumor Classification Dashboard')

# Load data and models
X, y = load_data()
X_train_flat, X_test_flat, y_train, y_test, X_train_img, X_test_img = split_data(X, y)
all_X = np.vstack((X_train_flat, X_test_flat))
all_y = np.hstack((y_train, y_test))
models = load_models()

# Sidebar model selection
selected_models = st.sidebar.multiselect(
    "Select Models to Evaluate", options=list(models.keys()), default=list(models.keys())
)
for model_name in selected_models:
    model = models[model_name]
    st.header(f"Model: {model_name}")

    # Predictions
    y_train_pred = model.predict(X_train_flat)
    y_test_pred = model.predict(X_test_flat)

    # Accuracy
    train_acc = accuracy_score(y_train, y_train_pred)
    test_acc = accuracy_score(y_test, y_test_pred)
    st.write(f"**Train Accuracy:** {train_acc:.4f}")
    st.write(f"**Test Accuracy:** {test_acc:.4f}")

    # Learning Curve
    with st.expander("Learning Curves"):
        sizes, tr_acc, cv_acc, tr_loss, cv_loss = compute_learning_curves(
            model, X_train_flat, y_train
        )
        fig, ax = plt.subplots(1, 2, figsize=(12, 4))
        # Accuracy curve
        ax[0].plot(sizes, tr_acc, 'o-', label='Train Acc')
        ax[0].plot(sizes, cv_acc, 'o-', label='CV Acc')
        ax[0].set(title='Accuracy', xlabel='Training samples', ylabel='Score')
        ax[0].legend(), ax[0].grid(True)
        # Loss curve
        ax[1].plot(sizes, tr_loss, 'o-', label='Train Loss')
        ax[1].plot(sizes, cv_loss, 'o-', label='CV Loss')
        ax[1].set(title='Log Loss', xlabel='Training samples', ylabel='Loss')
        ax[1].legend(), ax[1].grid(True)
        st.pyplot(fig)

    # Confusion Matrix
    with st.expander("Confusion Matrix"):
        cm = confusion_matrix(y_test, y_test_pred)
        fig3, ax3 = plt.subplots()
        ConfusionMatrixDisplay(cm, display_labels=list(CLASS_NAMES.values())).plot(ax=ax3, cmap='Blues')
        st.pyplot(fig3)

    # Classification Report
    with st.expander("Classification Report"):
        report = classification_report(y_test, y_test_pred, target_names=list(CLASS_NAMES.values()))
        st.text(report)

# Upload and Predict
st.header("Predict on New Image")
uploaded = st.file_uploader("Upload a brain tumor image (.png, .jpg)", type=['png','jpg','jpeg'])
if uploaded:
    file_bytes = np.frombuffer(uploaded.read(), np.uint8)
    img = cv2.imdecode(file_bytes, cv2.IMREAD_GRAYSCALE)
    img_resized = cv2.resize(img, (IMG_SIZE, IMG_SIZE)) / 255.0
    st.image(img_resized, caption='Uploaded Image', use_column_width=True, clamp=True)
    flat = img_resized.reshape(1, -1)
    for model_name in selected_models:
        model = models[model_name]
        pred = model.predict(flat)[0]
        st.write(f"**{model_name} Prediction:** {CLASS_NAMES[pred]}")
