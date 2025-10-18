# Quick Setup Guide for Haulistry Backend

Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      HAULISTRY BACKEND SETUP SCRIPT             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check Python installation
Write-Host "📌 Checking Python installation..." -ForegroundColor Yellow
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Python is installed: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "❌ Python is not installed. Please install Python 3.9 or higher." -ForegroundColor Red
    exit 1
}

# Create virtual environment
Write-Host ""
Write-Host "📌 Creating virtual environment..." -ForegroundColor Yellow
if (Test-Path "venv") {
    Write-Host "⚠️  Virtual environment already exists. Skipping..." -ForegroundColor Yellow
} else {
    python -m venv venv
    Write-Host "✅ Virtual environment created" -ForegroundColor Green
}

# Activate virtual environment
Write-Host ""
Write-Host "📌 Activating virtual environment..." -ForegroundColor Yellow
& .\venv\Scripts\Activate.ps1
Write-Host "✅ Virtual environment activated" -ForegroundColor Green

# Upgrade pip
Write-Host ""
Write-Host "📌 Upgrading pip..." -ForegroundColor Yellow
python -m pip install --upgrade pip
Write-Host "✅ Pip upgraded" -ForegroundColor Green

# Install dependencies
Write-Host ""
Write-Host "📌 Installing dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ All dependencies installed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

# Check for .env file
Write-Host ""
Write-Host "📌 Checking configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "✅ .env file found" -ForegroundColor Green
} else {
    Write-Host "⚠️  .env file not found. Creating from .env.example..." -ForegroundColor Yellow
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "✅ .env file created. Please update with your credentials." -ForegroundColor Green
    } else {
        Write-Host "❌ .env.example not found" -ForegroundColor Red
    }
}

# Check for Firebase credentials
Write-Host ""
Write-Host "📌 Checking Firebase credentials..." -ForegroundColor Yellow
if (Test-Path "firebase-credentials.json") {
    Write-Host "✅ Firebase credentials file found" -ForegroundColor Green
} else {
    Write-Host "⚠️  firebase-credentials.json not found" -ForegroundColor Yellow
    Write-Host "   Please download from Firebase Console:" -ForegroundColor Yellow
    Write-Host "   1. Go to Firebase Console → Project Settings" -ForegroundColor Cyan
    Write-Host "   2. Click 'Service Accounts' tab" -ForegroundColor Cyan
    Write-Host "   3. Click 'Generate New Private Key'" -ForegroundColor Cyan
    Write-Host "   4. Save as 'firebase-credentials.json' in this directory" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║           SETUP COMPLETED SUCCESSFULLY!          ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 To start the server, run:" -ForegroundColor Cyan
Write-Host "   python main.py" -ForegroundColor White
Write-Host ""
Write-Host "📚 API Documentation will be available at:" -ForegroundColor Cyan
Write-Host "   http://localhost:8000/docs" -ForegroundColor White
Write-Host ""
