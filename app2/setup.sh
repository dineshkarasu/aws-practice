#!/bin/bash

# App2 Setup and Run Script
set -e

echo "=========================================="
echo "🚀 App2 Setup Script"
echo "=========================================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18 or higher."
    exit 1
fi

NODE_VERSION=$(node -v)
echo "✅ Node.js version: $NODE_VERSION"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed."
    exit 1
fi

NPM_VERSION=$(npm -v)
echo "✅ npm version: $NPM_VERSION"
echo ""

# Install backend dependencies
echo "📦 Step 1/4: Installing backend dependencies..."
npm install
echo "✅ Backend dependencies installed"
echo ""

# Install frontend dependencies
echo "📦 Step 2/4: Installing frontend dependencies..."
cd frontend
npm install
cd ..
echo "✅ Frontend dependencies installed"
echo ""

# Build frontend
echo "🔨 Step 3/4: Building frontend..."
npm run build:frontend
echo "✅ Frontend built successfully"
echo ""

# Start server
echo "🚀 Step 4/4: Starting server..."
echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "Starting App2 server on http://localhost:4000"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

npm start
