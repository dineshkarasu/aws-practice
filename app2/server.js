const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 4000;
const NODE_ENV = process.env.NODE_ENV || 'production';

// Middleware
app.use(cors());
app.use(express.json());

// API Routes (must come before static file serving)
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    app: 'app2',
    environment: NODE_ENV,
    timestamp: new Date().toISOString()
  });
});

app.get('/api/message', (req, res) => {
  res.json({ 
    message: 'Hello from App 2 Backend',
    timestamp: new Date().toISOString()
  });
});

// Check if build folder exists
const buildPath = path.join(__dirname, 'frontend/build');
const buildExists = fs.existsSync(buildPath);

if (buildExists) {
  // Serve static files from React build
  app.use(express.static(buildPath));
  
  // Serve React app for all other routes
  app.get('*', (req, res) => {
    res.sendFile(path.join(buildPath, 'index.html'));
  });
  
  console.log('✅ Serving React build from:', buildPath);
} else {
  console.log('⚠️  Frontend build not found. Run "npm run build" first.');
  console.log('   Build path:', buildPath);
  
  // Fallback route for development
  app.get('*', (req, res) => {
    res.status(503).json({
      error: 'Frontend not built',
      message: 'Please run "npm run build" to build the frontend',
      apis: {
        health: '/api/health',
        message: '/api/message'
      }
    });
  });
}

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err.message);
  res.status(500).json({ 
    error: 'Internal Server Error',
    message: err.message 
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log('\n' + '='.repeat(50));
  console.log(`🚀 App2 Server running`);
  console.log('='.repeat(50));
  console.log(`📍 URL:        http://localhost:${PORT}`);
  console.log(`🌍 Environment: ${NODE_ENV}`);
  console.log(`📡 Health:      http://localhost:${PORT}/api/health`);
  console.log(`💬 Message:     http://localhost:${PORT}/api/message`);
  console.log('='.repeat(50) + '\n');
});
