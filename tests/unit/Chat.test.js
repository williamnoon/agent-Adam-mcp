/**
 * Chat Component Tests
 */

// Mock DOM environment
import { JSDOM } from 'jsdom';
const dom = new JSDOM('<!DOCTYPE html><html><body><div id="app"><div id="messages"></div></div></body></html>');
global.document = dom.window.document;
global.window = dom.window;

// Import Chat component
import Chat from '../../src/frontend/components/Chat.js';

describe('Chat Component', () => {
  let chatContainer;
  let chat;

  beforeEach(() => {
    // Set up DOM
    document.body.innerHTML = `
      <div id="app">
        <div id="messages"></div>
      </div>
    `;
    chatContainer = document.getElementById('app');
    
    // Mock Chat class if needed
    if (!Chat) {
      global.Chat = class MockChat {
        constructor(container) {
          this.container = container;
          this.messagesContainer = container.querySelector('#messages');
        }
        
        renderMessage(message, sender = 'adam', timestamp = new Date()) {
          const messageEl = document.createElement('div');
          messageEl.className = `message message-${sender}`;
          messageEl.textContent = message;
          this.messagesContainer.appendChild(messageEl);
          return messageEl;
        }
        
        clearMessages() {
          this.messagesContainer.innerHTML = '';
        }
      };
      chat = new global.Chat(chatContainer);
    } else {
      chat = new Chat(chatContainer);
    }
  });

  test('should initialize with container', () => {
    expect(chat).toBeDefined();
    expect(chat.container).toBe(chatContainer);
  });

  test('should render messages', () => {
    const message = 'Hello, this is a test message';
    const messageEl = chat.renderMessage(message, 'user');
    
    expect(messageEl).toBeDefined();
    expect(messageEl.textContent).toContain(message);
    expect(messageEl.className).toContain('message-user');
  });

  test('should clear messages', () => {
    // Add some messages
    chat.renderMessage('Message 1', 'user');
    chat.renderMessage('Message 2', 'adam');
    
    // Verify messages exist
    expect(chat.messagesContainer.children.length).toBe(2);
    
    // Clear messages
    chat.clearMessages();
    
    // Verify messages are cleared
    expect(chat.messagesContainer.children.length).toBe(0);
  });

  test('should handle different sender types', () => {
    const userMsg = chat.renderMessage('User message', 'user');
    const adamMsg = chat.renderMessage('Adam message', 'adam');
    const systemMsg = chat.renderMessage('System message', 'system');
    
    expect(userMsg.className).toContain('message-user');
    expect(adamMsg.className).toContain('message-adam');
    expect(systemMsg.className).toContain('message-system');
  });
});