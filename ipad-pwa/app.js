/* =========================================================
   Lil Agents - iPad Pro Edition
   Simulation of Bruce & Jazz walking companions + AI Terminal
   ========================================================= */

// Sounds Pool
const SOUNDS = [
  'assets/sounds/ping-aa.mp3',
  'assets/sounds/ping-bb.mp3',
  'assets/sounds/ping-cc.mp3',
  'assets/sounds/ping-dd.mp3',
  'assets/sounds/ping-ee.mp3',
  'assets/sounds/ping-ff.mp3',
  'assets/sounds/ping-gg.mp3',
  'assets/sounds/ping-hh.mp3'
];

const THINKING_PHRASES = [
  "hmm...", "thinking...", "one sec...", "ok hold on",
  "let me check", "working on it", "almost...", "bear with me",
  "on it!", "gimme a sec", "brb", "processing...",
  "hang tight", "just a moment", "figuring it out",
  "crunching...", "reading...", "looking...",
  "cooking...", "vibing...", "digging in",
  "connecting dots", "give me a sec",
  "don't rush me", "calculating...", "assembling…"
];

const COMPLETION_PHRASES = [
  "done!", "all set!", "ready!", "here you go", "got it!",
  "finished!", "ta-da!", "voila!", "boom!", "there ya go!", "check it out!"
];

class Character {
  constructor(config) {
    this.name = config.name;
    this.element = document.getElementById(config.elementId);
    this.video = document.getElementById(config.videoId);
    this.bubbleContainer = document.getElementById(config.bubbleId);
    this.bubbleText = document.getElementById(config.bubbleTextId);
    this.color = config.color;

    // Movement Physics
    this.x = config.initialX || 100;
    this.speed = config.speed || 1.2;
    this.direction = 1; // 1 = right, -1 = left
    this.isPaused = false;
    this.pauseTimer = 0;
    this.travelRemaining = config.travelDistance || 250;
    this.isActive = true;

    // Thinking state
    this.isBusy = false;
    this.phraseInterval = null;
    this.completionTimer = null;

    this.init();
  }

  init() {
    this.updatePosition();
    this.showBubble("hi!", true, 5000);

    // Click character to open terminal
    this.element.addEventListener('click', (e) => {
      e.stopPropagation();
      openTerminal(this.name);
    });

    // Make sure video plays
    this.video.play().catch(() => {
      // Autoplay might need user interaction
      document.body.addEventListener('click', () => this.video.play(), { once: true });
    });
  }

  updatePosition() {
    this.element.style.left = `${this.x}px`;
    if (this.direction === -1) {
      this.element.classList.add('flip-x');
    } else {
      this.element.classList.remove('flip-x');
    }
  }

  step(boundsWidth) {
    if (!this.isActive) return;

    if (this.isPaused) {
      this.pauseTimer -= 16;
      if (this.pauseTimer <= 0) {
        this.isPaused = false;
        this.travelRemaining = 120 + Math.random() * 280;
        // 40% chance to flip direction after pause
        if (Math.random() < 0.4) {
          this.direction *= -1;
        }
      }
      return;
    }

    // Move
    this.x += this.speed * this.direction;
    this.travelRemaining -= Math.abs(this.speed);

    // Check bounds
    const charWidth = this.element.offsetWidth || 130;
    const minX = 20;
    const maxX = boundsWidth - charWidth - 20;

    if (this.x >= maxX) {
      this.x = maxX;
      this.direction = -1;
      this.pause();
    } else if (this.x <= minX) {
      this.x = minX;
      this.direction = 1;
      this.pause();
    } else if (this.travelRemaining <= 0) {
      this.pause();
    }

    this.updatePosition();
  }

  pause() {
    this.isPaused = true;
    this.pauseTimer = 1500 + Math.random() * 3000;
  }

  showBubble(text, isCompletion = false, autoHideMs = 3000) {
    if (!this.bubbleContainer || !this.bubbleText) return;
    this.bubbleText.textContent = text;
    this.bubbleContainer.classList.add('visible');
    if (isCompletion) {
      this.bubbleContainer.classList.add('completion');
    } else {
      this.bubbleContainer.classList.remove('completion');
    }

    if (autoHideMs > 0) {
      clearTimeout(this.completionTimer);
      this.completionTimer = setTimeout(() => {
        this.hideBubble();
      }, autoHideMs);
    }
  }

  hideBubble() {
    if (!this.bubbleContainer) return;
    this.bubbleContainer.classList.remove('visible');
    this.bubbleContainer.classList.remove('completion');
  }

  startThinking() {
    this.isBusy = true;
    const pickPhrase = () => {
      const phrase = THINKING_PHRASES[Math.floor(Math.random() * THINKING_PHRASES.length)];
      this.showBubble(phrase, false, 0);
    };
    pickPhrase();
    this.phraseInterval = setInterval(pickPhrase, 2200);
  }

  stopThinking(playSound = true) {
    this.isBusy = false;
    clearInterval(this.phraseInterval);
    const phrase = COMPLETION_PHRASES[Math.floor(Math.random() * COMPLETION_PHRASES.length)];
    this.showBubble(phrase, true, 4000);
    if (playSound) playChime();
  }
}

// Sound Player
function playChime() {
  if (localStorage.getItem('lilagents_sound') === 'off') return;
  const audio = document.getElementById('snd-ping');
  if (audio) {
    const file = SOUNDS[Math.floor(Math.random() * SOUNDS.length)];
    audio.src = file;
    audio.play().catch(e => console.log('Audio error:', e));
  }
}

// State & UI References
let bruce, jazz;
let activeCharacterName = 'Bruce';
let lastResponseText = '';

// DOM Elements
const stage = document.getElementById('stage');
const terminalPopover = document.getElementById('terminalPopover');
const terminalTitle = document.getElementById('terminalTitle');
const activeDot = document.getElementById('activeDot');
const chatHistory = document.getElementById('chatHistory');
const chatInput = document.getElementById('chatInput');
const btnSend = document.getElementById('btnSend');
const btnCopyLast = document.getElementById('btnCopyLast');
const btnClearChat = document.getElementById('btnClearChat');
const btnCloseTerminal = document.getElementById('btnCloseTerminal');
const themeSelect = document.getElementById('themeSelect');
const toggleSound = document.getElementById('toggleSound');
const soundIcon = document.getElementById('soundIcon');
const openSettings = document.getElementById('openSettings');
const settingsModal = document.getElementById('settingsModal');
const closeSettingsBtn = document.getElementById('closeSettingsBtn');
const saveSettingsBtn = document.getElementById('saveSettingsBtn');
const providerSelect = document.getElementById('providerSelect');
const apiKeyInput = document.getElementById('apiKeyInput');
const charSizeSelect = document.getElementById('charSizeSelect');
const toggleBruce = document.getElementById('toggleBruce');
const toggleJazz = document.getElementById('toggleJazz');

// Initialize Characters
function initApp() {
  const stageWidth = window.innerWidth;
  bruce = new Character({
    name: 'Bruce',
    elementId: 'walker-bruce',
    videoId: 'video-bruce',
    bubbleId: 'bubble-bruce',
    bubbleTextId: 'bubble-text-bruce',
    color: '#66b88c',
    initialX: stageWidth * 0.25,
    speed: 1.15
  });

  jazz = new Character({
    name: 'Jazz',
    elementId: 'walker-jazz',
    videoId: 'video-jazz',
    bubbleId: 'bubble-jazz',
    bubbleTextId: 'bubble-text-jazz',
    color: '#ff6600',
    initialX: stageWidth * 0.65,
    speed: 1.3
  });

  // Settings Load
  const savedTheme = localStorage.getItem('lilagents_theme') || 'Midnight';
  setTheme(savedTheme);
  themeSelect.value = savedTheme;

  const savedSound = localStorage.getItem('lilagents_sound') || 'on';
  setSound(savedSound === 'on');

  const savedProvider = localStorage.getItem('lilagents_provider') || 'gemini';
  providerSelect.value = savedProvider;
  apiKeyInput.value = localStorage.getItem(`lilagents_key_${savedProvider}`) || '';

  const savedSize = localStorage.getItem('lilagents_size') || 'medium';
  charSizeSelect.value = savedSize;
  setCharacterSize(savedSize);

  // Animation Loop
  function loop() {
    const width = window.innerWidth;
    bruce.step(width);
    jazz.step(width);
    requestAnimationFrame(loop);
  }
  requestAnimationFrame(loop);

  // Initial welcome in terminal
  appendMessage('system', 'Lil Agents initialized for iPad Pro (M1). Tap Bruce or Jazz anytime to chat. Type /help for slash commands.');
}

// Terminal Open / Close
function openTerminal(charName) {
  activeCharacterName = charName;
  const char = charName === 'Bruce' ? bruce : jazz;
  const provider = (localStorage.getItem('lilagents_provider') || 'gemini').toUpperCase();
  
  terminalTitle.textContent = `${char.name.toUpperCase()} // ${provider}`;
  activeDot.style.background = char.color;
  chatInput.placeholder = `Ask ${char.name}... (type /help for commands)`;
  
  terminalPopover.classList.add('open');
  chatInput.focus();
}

function closeTerminal() {
  terminalPopover.classList.remove('open');
}

// Chat UI helpers
function appendMessage(sender, text, isUser = false) {
  const item = document.createElement('div');
  item.className = `message-item ${isUser ? 'user' : 'agent'}`;

  const header = document.createElement('div');
  header.className = 'message-header';
  header.textContent = sender;

  const bubble = document.createElement('div');
  bubble.className = 'message-bubble';
  bubble.innerHTML = formatMarkdown(text);

  item.appendChild(header);
  item.appendChild(bubble);
  chatHistory.appendChild(item);
  chatHistory.scrollTop = chatHistory.scrollHeight;

  if (!isUser && sender !== 'System') {
    lastResponseText = text;
  }
}

function formatMarkdown(text) {
  if (!text) return '';
  // Basic markdown conversion
  let html = text
    .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    .replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>')
    .replace(/`([^`]+)`/g, '<code style="background: rgba(255,255,255,0.1); padding: 2px 5px; border-radius: 4px;">$1</code>')
    .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
    .replace(/\*([^*]+)\*/g, '<em>$1</em>')
    .replace(/\n/g, '<br/>');
  return html;
}

// Send Message Flow
async function handleSend() {
  const query = chatInput.value.trim();
  if (!query) return;
  chatInput.value = '';

  // Handle Slash Commands
  if (query.startsWith('/')) {
    handleSlashCommand(query);
    return;
  }

  const activeChar = activeCharacterName === 'Bruce' ? bruce : jazz;
  appendMessage('You', query, true);

  // Set character thinking
  activeChar.startThinking();
  btnSend.disabled = true;

  try {
    const response = await queryAIProvider(query);
    activeChar.stopThinking(true);
    appendMessage(activeChar.name, response);
  } catch (err) {
    activeChar.stopThinking(false);
    appendMessage(activeChar.name, `⚠️ Error: ${err.message || 'Could not reach AI provider'}`);
  } finally {
    btnSend.disabled = false;
    chatInput.focus();
  }
}

// Slash Command Parser
function handleSlashCommand(cmd) {
  const [action, ...args] = cmd.split(' ');
  switch (action.toLowerCase()) {
    case '/clear':
      chatHistory.innerHTML = '';
      appendMessage('System', 'Terminal cleared.');
      break;
    case '/copy':
      if (lastResponseText) {
        navigator.clipboard.writeText(lastResponseText);
        appendMessage('System', 'Copied last response to clipboard.');
      } else {
        appendMessage('System', 'No response available to copy.');
      }
      break;
    case '/theme':
      if (args[0] && ['Midnight', 'Peach', 'Cloud', 'Moss'].includes(args[0])) {
        setTheme(args[0]);
        themeSelect.value = args[0];
        appendMessage('System', `Theme changed to ${args[0]}.`);
      } else {
        appendMessage('System', 'Usage: /theme [Midnight | Peach | Cloud | Moss]');
      }
      break;
    case '/help':
      appendMessage('System', `Available commands:\n• /clear - Clear chat messages\n• /copy - Copy last agent response\n• /theme [name] - Switch visual theme\n• /help - Display this help manual`);
      break;
    default:
      appendMessage('System', `Unknown command '${action}'. Type /help for available commands.`);
  }
}

// AI Provider Integration
async function queryAIProvider(prompt) {
  const provider = localStorage.getItem('lilagents_provider') || 'gemini';
  const apiKey = localStorage.getItem(`lilagents_key_${provider}`) || '';

  if (provider === 'demo' || !apiKey) {
    // Demo / Offline Mode Responses
    await new Promise(r => setTimeout(r, 1200));
    return generateLocalDemoResponse(prompt);
  }

  if (provider === 'gemini') {
    // Google Gemini API call
    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;
    const res = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: `You are ${activeCharacterName}, a tiny AI companion walking on the iPad dock. Keep responses helpful, witty, and concise.\n\nUser: ${prompt}` }] }]
      })
    });
    const data = await res.json();
    if (data.error) throw new Error(data.error.message);
    return data.candidates?.[0]?.content?.parts?.[0]?.text || "I'm thinking, but got no words back!";
  }

  if (provider === 'claude') {
    // Anthropic Claude Messages API
    const res = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
        'anthropic-dangerous-direct-browser-access': 'true'
      },
      body: JSON.stringify({
        model: 'claude-3-5-sonnet-20241022',
        max_tokens: 1024,
        messages: [{ role: 'user', content: prompt }]
      })
    });
    const data = await res.json();
    if (data.error) throw new Error(data.error.message);
    return data.content?.[0]?.text || 'No response from Claude.';
  }

  if (provider === 'openai') {
    // OpenAI API
    const res = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: `You are ${activeCharacterName}, a tiny AI agent on iPad Pro.` },
          { role: 'user', content: prompt }
        ]
      })
    });
    const data = await res.json();
    if (data.error) throw new Error(data.error.message);
    return data.choices?.[0]?.message?.content || 'No response from OpenAI.';
  }

  return generateLocalDemoResponse(prompt);
}

// Local Demo Intelligence
function generateLocalDemoResponse(prompt) {
  const lower = prompt.toLowerCase();
  const name = activeCharacterName;
  if (lower.includes('hello') || lower.includes('hi') || lower.includes('hey')) {
    return `Hey there! I'm ${name}, your lil agent. I'm taking a walk right on your iPad dock. What are we hacking on today?`;
  }
  if (lower.includes('who are you') || lower.includes('what can you do')) {
    return `I'm ${name}! Along with my buddy ${name === 'Bruce' ? 'Jazz' : 'Bruce'}, we wander across your screen, vibe, and help you think through code, ideas, or questions. You can configure my live Gemini, Claude, or OpenAI API key in Settings (⚙️)!`;
  }
  if (lower.includes('joke')) {
    return `Why did the AI cross the road? To optimize the travel heuristic between sidewalks! (And because the dock ended!) 😄`;
  }
  return `"${prompt}" — great question! In Demo Mode, I am simulating responses locally. To unlock full real-time intelligence with Gemini, Claude, or GPT-4o, tap the gear icon (⚙️) and enter your API key!`;
}

// Theme & Settings Handlers
function setTheme(theme) {
  document.body.setAttribute('data-theme', theme);
  localStorage.setItem('lilagents_theme', theme);
}

function setSound(enabled) {
  if (enabled) {
    localStorage.setItem('lilagents_sound', 'on');
    soundIcon.textContent = '🔊';
  } else {
    localStorage.setItem('lilagents_sound', 'off');
    soundIcon.textContent = '🔇';
  }
}

function setCharacterSize(size) {
  localStorage.setItem('lilagents_size', size);
  const heights = { small: '120px', medium: '160px', large: '210px' };
  const widths = { small: '80px', medium: '110px', large: '140px' };
  const h = heights[size] || '160px';
  const w = widths[size] || '110px';

  document.querySelectorAll('.walker-item').forEach(el => {
    el.style.height = h;
    el.style.width = w;
  });
}

// Event Listeners Setup
themeSelect.addEventListener('change', (e) => setTheme(e.target.value));

toggleSound.addEventListener('click', () => {
  const current = localStorage.getItem('lilagents_sound') !== 'off';
  setSound(!current);
});

toggleBruce.addEventListener('click', () => {
  bruce.isActive = !bruce.isActive;
  toggleBruce.classList.toggle('active', bruce.isActive);
  document.getElementById('walker-bruce').style.display = bruce.isActive ? 'flex' : 'none';
});

toggleJazz.addEventListener('click', () => {
  jazz.isActive = !jazz.isActive;
  toggleJazz.classList.toggle('active', jazz.isActive);
  document.getElementById('walker-jazz').style.display = jazz.isActive ? 'flex' : 'none';
});

// Dock Click handlers
document.getElementById('dockBruce').addEventListener('click', () => openTerminal('Bruce'));
document.getElementById('dockJazz').addEventListener('click', () => openTerminal('Jazz'));
document.getElementById('dockTerminal').addEventListener('click', () => openTerminal(activeCharacterName));
document.getElementById('dockSettings').addEventListener('click', () => settingsModal.classList.add('open'));
document.getElementById('dockNotes').addEventListener('click', () => {
  openTerminal(activeCharacterName);
  appendMessage('Notes', '📝 Quick Scratchpad:\n- iPad Pro 11" M1 setup active\n- Stage Manager ready\n- Offline & streaming support enabled');
});

// Terminal buttons
btnSend.addEventListener('click', handleSend);
chatInput.addEventListener('keydown', (e) => {
  if (e.key === 'Enter') handleSend();
  if (e.key === 'Escape') closeTerminal();
});

btnCopyLast.addEventListener('click', () => {
  if (lastResponseText) {
    navigator.clipboard.writeText(lastResponseText);
    bruce.showBubble("copied!", true, 2000);
  }
});

btnClearChat.addEventListener('click', () => {
  chatHistory.innerHTML = '';
  appendMessage('System', 'Terminal history cleared.');
});

btnCloseTerminal.addEventListener('click', closeTerminal);

// Settings Modal Handlers
openSettings.addEventListener('click', () => {
  const provider = localStorage.getItem('lilagents_provider') || 'gemini';
  providerSelect.value = provider;
  apiKeyInput.value = localStorage.getItem(`lilagents_key_${provider}`) || '';
  settingsModal.classList.add('open');
});

closeSettingsBtn.addEventListener('click', () => settingsModal.classList.remove('open'));

providerSelect.addEventListener('change', (e) => {
  const provider = e.target.value;
  apiKeyInput.value = localStorage.getItem(`lilagents_key_${provider}`) || '';
});

saveSettingsBtn.addEventListener('click', () => {
  const provider = providerSelect.value;
  localStorage.setItem('lilagents_provider', provider);
  if (apiKeyInput.value) {
    localStorage.setItem(`lilagents_key_${provider}`, apiKeyInput.value.trim());
  }
  const size = charSizeSelect.value;
  setCharacterSize(size);

  settingsModal.classList.remove('open');
  const activeChar = activeCharacterName === 'Bruce' ? bruce : jazz;
  activeChar.showBubble('saved!', true, 2000);
  playChime();
});

// PWA Service Worker Registration
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('sw.js').catch(err => {
      console.log('SW registration note:', err);
    });
  });
}

// Start
window.addEventListener('DOMContentLoaded', initApp);
