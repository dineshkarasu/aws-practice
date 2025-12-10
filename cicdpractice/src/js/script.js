// Get elements
const greeting = document.getElementById('greeting');
const changeBtn = document.getElementById('changeBtn');
const message = document.getElementById('message');

// Array of greetings
const greetings = [
    'Hello World!',
    'Bonjour le Monde!',
    'Hola Mundo!',
    'Ciao Mondo!',
    'Hallo Welt!',
    'こんにちは世界!',
    'Привет мир!'
];

let currentIndex = 0;

// Button click event
changeBtn.addEventListener('click', () => {
    currentIndex = (currentIndex + 1) % greetings.length;
    greeting.textContent = greetings[currentIndex];
    
    // Show message
    const now = new Date();
    message.textContent = `Updated at ${now.toLocaleTimeString()}`;
    
    // Add animation effect
    greeting.style.transform = 'scale(1.1)';
    setTimeout(() => {
        greeting.style.transform = 'scale(1)';
    }, 200);
});

// Log to console
console.log('Hello World app loaded successfully!');
