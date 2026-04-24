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
python -m pip install --user -r requirements.txt
if errorlevel 1 (
    echo Failed to install required packages
    pause
    exit /b 1
)

echo Starting Flask servers...
start /b "" pythonw "ML_Model\FlaskForClassification.py"
start /b "" pythonw "ML_Model\FlaskForRegression.py"

:: Wait for servers to start
timeout /t 3 > nul

:: Start the Flutter app
start "" "flutter_ml\build\windows\x64\runner\Debug\flutter_ml.exe"

exit
