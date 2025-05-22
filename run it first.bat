@echo off
echo Checking Python installation...

:: Check if Python is installed
python --version > nul 2>&1
if errorlevel 1 (
    echo Python is not installed or not in PATH
    echo Please install Python and make sure to check "Add to PATH" during installation
    pause
    exit /b 1
)

echo Installing required Python packages...

:: Install required packages using python -m pip
python -m pip install --user flask flask-cors pillow numpy scikit-learn joblib
if errorlevel 1 (
    echo Failed to install required packages
    pause
    exit /b 1
)

echo Starting Flask servers...

:: Set the path to ML_Model directory
set "ML_PATH=the-magnificent-three\ML_Model"

:: Start servers without showing CMD windows
start /b "" pythonw "%ML_PATH%\FlaskForClassification.py"
start /b "" pythonw "%ML_PATH%\FlaskForRegression.py"

:: Wait for servers to start
timeout /t 3 > nul

:: Start the Flutter app
start "" "flutter_ml\build\windows\x64\runner\Debug.exe"

:: Exit the batch script
exit 