import React, { useState } from 'react';
import './App.css';

function App() {
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);

  const getMessage = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/message');
      const data = await response.json();
      setMessage(data.message);
    } catch (error) {
      setMessage('Error fetching message');
      console.error('Error:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <div className="container">
        <h1>App 2 - Full Stack</h1>
        <p className="subtitle">Node.js/Express + React</p>
        
        <button 
          className="btn-primary" 
          onClick={getMessage}
          disabled={loading}
        >
          {loading ? 'Loading...' : 'Get Message'}
        </button>
        
        {message && (
          <div className="message-box">
            <p>{message}</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
