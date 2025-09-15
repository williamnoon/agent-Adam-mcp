/**
 * Agent Adam - Main Application
 * Initializes the frontend application and handles user interactions
 */

import icpService from './services/ICPService.js';
import demoICPService from './services/DemoICPService.js';
import Chat from './components/Chat.js';

class AgentAdamApp {
  constructor() {
    this.chat = null;
    this.icpService = icpService;
    this.demoMode = false;
    this.isInitialized = false;
    this.locationId = 'default';
    this.userId = 'web-user';
    
    this.init();
  }

  async init() {
    try {
      // Initialize UI components
      this.initializeUI();
      
      // Initialize ICP service
      await this.initializeICP();
      
      // Set up event listeners
      this.setupEventListeners();
      
      // Setup GHL bridge for iframe communication
      this.setupGHLBridge();
      
      this.isInitialized = true;
      console.log('Agent Adam initialized successfully');
      
      // Show welcome message
      this.showWelcomeMessage();
      
    } catch (error) {
      console.error('Failed to initialize Agent Adam:', error);
      this.showErrorMessage('Failed to initialize. Please refresh the page.');
    }
  }

  initializeUI() {
    // Initialize chat component
    const chatContainer = document.getElementById('app');
    if (chatContainer) {
      this.chat = new Chat(chatContainer);
    }
    
    // Initialize quick actions
    this.initializeQuickActions();
    
    // Initialize sidebar
    this.initializeSidebar();
    
    // Update status indicator
    this.updateStatus('initializing', 'Initializing...');
  }

  async initializeICP() {
    try {
      // Try to initialize real ICP service first
      const success = await this.icpService.init();
      if (success) {
        this.updateStatus('online', 'Connected to ICP');
        await this.loadInitialData();
        this.demoMode = false;
      } else {
        throw new Error('ICP service initialization failed');
      }
    } catch (error) {
      console.warn('ICP service failed, switching to demo mode:', error);
      
      // Fall back to demo mode
      this.icpService = demoICPService;
      await this.icpService.init();
      this.demoMode = true;
      this.updateStatus('online', 'Demo Mode');
      await this.loadInitialData();
      
      // Show demo mode message
      if (this.chat) {
        this.chat.addSystemMessage(
          '🚀 Agent Adam is running in Demo Mode. All features are functional for testing!', 
          'info'
        );
      }
    }
  }

  async loadInitialData() {
    try {
      // Get canister status
      const status = await this.icpService.getStatus();
      this.updateSidebarStats(status);
      
      // Load recent command history
      const history = await this.icpService.getHistory(5);
      this.updateRecentActivity(history);
      
    } catch (error) {
      console.error('Failed to load initial data:', error);
    }
  }

  setupEventListeners() {
    // Command input handling
    const commandInput = document.getElementById('commandInput');
    const sendButton = document.getElementById('sendButton');
    
    if (commandInput && sendButton) {
      // Send on button click
      sendButton.addEventListener('click', () => {
        this.handleUserInput();
      });
      
      // Send on Enter key
      commandInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
          e.preventDefault();
          this.handleUserInput();
        }
      });
      
      // Auto-resize input
      commandInput.addEventListener('input', () => {
        this.autoResizeInput(commandInput);
      });
    }
    
    // Quick reply handling
    if (this.chat && this.chat.container) {
      this.chat.container.addEventListener('quickReply', (e) => {
        this.handleQuickReply(e.detail.reply);
      });
    }
    
    // Window events
    window.addEventListener('beforeunload', () => {
      this.cleanup();
    });
  }

  initializeQuickActions() {
    const quickActions = document.querySelectorAll('.quick-action');
    quickActions.forEach(action => {
      action.addEventListener('click', (e) => {
        const command = e.target.getAttribute('data-command');
        if (command) {
          this.processCommand(command);
        }
      });
    });
  }

  initializeSidebar() {
    // Initialize metrics display
    this.updateSidebarStats({
      totalCommands: 0,
      isOnline: true
    });
    
    // Add activity
    this.addActivityItem('System initialized', 'Just now');
  }

  setupGHLBridge() {
    // Listen for messages from parent window (GHL)
    window.addEventListener('message', (event) => {
      // Validate origin for security
      if (!event.origin.includes('gohighlevel.com') && 
          !event.origin.includes('localhost') && 
          !event.origin.includes('127.0.0.1')) {
        return;
      }
      
      this.handleGHLMessage(event.data);
    });
    
    // Send ready message to parent
    this.sendToParent({
      type: 'adam-ready',
      timestamp: Date.now()
    });
  }

  handleGHLMessage(data) {
    switch (data.type) {
      case 'ghl-context':
        this.locationId = data.locationId || 'default';
        this.userId = data.userId || 'web-user';
        console.log('Received GHL context:', { locationId: this.locationId, userId: this.userId });
        break;
        
      case 'ghl-command':
        this.processCommand(data.command, data.context);
        break;
        
      case 'ghl-webhook':
        this.handleWebhook(data.webhookId, data.eventType, data.payload);
        break;
        
      default:
        console.log('Unknown GHL message type:', data.type);
    }
  }

  sendToParent(data) {
    if (window.parent !== window) {
      window.parent.postMessage(data, '*');
    }
  }

  async handleUserInput() {
    const commandInput = document.getElementById('commandInput');
    if (!commandInput) return;
    
    const command = commandInput.value.trim();
    if (!command) return;
    
    // Clear input
    commandInput.value = '';
    
    // Process command
    await this.processCommand(command);
  }

  async processCommand(command, context = {}) {
    if (!this.chat) return;
    
    try {
      // Show user message
      this.chat.renderMessage(command, 'user', new Date());
      
      // Show typing indicator
      this.chat.showTypingIndicator('adam');
      
      // Process command through ICP
      const executionContext = {
        locationId: this.locationId,
        source: 'web-interface',
        ...context
      };
      
      const result = await this.icpService.processCommand(command, executionContext);
      
      // Hide typing indicator
      this.chat.hideTypingIndicator();
      
      // Show response
      this.handleCommandResult(result);
      
      // Update activity
      this.addActivityItem(`Processed: ${command.substring(0, 30)}...`, 'Just now');
      
      // Update stats
      this.refreshStats();
      
    } catch (error) {
      console.error('Command processing error:', error);
      this.chat.hideTypingIndicator();
      this.chat.addErrorMessage(error.message || 'Failed to process command');
    }
  }

  handleCommandResult(result) {
    if (!this.chat || !result) return;
    
    // Format response message
    let message = result.insights && result.insights.length > 0 
      ? result.insights.join('\n') 
      : 'Command processed successfully.';
    
    // Add action summary if available
    if (result.actions && result.actions.length > 0) {
      message += '\n\n**Actions taken:**\n';
      result.actions.forEach(action => {
        message += `• ${action.description}\n`;
      });
    }
    
    // Prepare quick replies from next steps
    const quickReplies = result.nextSteps && result.nextSteps.length > 0 
      ? result.nextSteps.slice(0, 3)  // Limit to 3 quick replies
      : ['Got it!', 'What else can you do?'];
    
    // Render response
    this.chat.renderMessage(message, 'adam', new Date(), {
      quickReplies: quickReplies
    });
    
    // Send result to parent window if in iframe
    this.sendToParent({
      type: 'adam-response',
      result: result,
      timestamp: Date.now()
    });
  }

  async handleQuickReply(reply) {
    await this.processCommand(reply);
  }

  async handleWebhook(webhookId, eventType, payload) {
    try {
      const result = await this.icpService.handleWebhook(
        webhookId, 
        eventType, 
        payload, 
        this.locationId
      );
      
      // Show webhook notification
      this.chat.addSystemMessage(
        `Webhook received: ${eventType}`, 
        'info'
      );
      
      this.addActivityItem(`Webhook: ${eventType}`, 'Just now');
      
    } catch (error) {
      console.error('Webhook handling error:', error);
      this.chat.addErrorMessage(`Webhook processing failed: ${error.message}`);
    }
  }

  updateStatus(status, message) {
    const statusElement = document.getElementById('statusText');
    const indicator = document.querySelector('.status-indicator');
    
    if (statusElement) {
      statusElement.textContent = message;
    }
    
    if (indicator) {
      indicator.className = `status-indicator status-${status}`;
    }
  }

  updateSidebarStats(stats) {
    const elements = {
      totalCommands: document.getElementById('recentCommands'),
      activeWorkflows: document.getElementById('activeWorkflows'),
      totalContacts: document.getElementById('totalContacts')
    };
    
    if (elements.totalCommands) {
      elements.totalCommands.textContent = stats.totalCommands || '0';
    }
    
    if (elements.activeWorkflows) {
      elements.activeWorkflows.textContent = stats.activeWorkflows || '-';
    }
    
    if (elements.totalContacts) {
      elements.totalContacts.textContent = stats.totalContacts || '-';
    }
  }

  updateRecentActivity(history) {
    if (!history || history.length === 0) return;
    
    const activityList = document.getElementById('activityList');
    if (!activityList) return;
    
    // Clear existing activity (except system initialized)
    const systemItems = activityList.querySelectorAll('.activity-item.system');
    activityList.innerHTML = '';
    systemItems.forEach(item => activityList.appendChild(item));
    
    // Add recent commands
    history.forEach(command => {
      this.addActivityItem(
        command.instruction.substring(0, 30) + '...',
        this.formatTimestamp(command.timestamp)
      );
    });
  }

  addActivityItem(description, time) {
    const activityList = document.getElementById('activityList');
    if (!activityList) return;
    
    const item = document.createElement('div');
    item.className = 'activity-item';
    item.innerHTML = `
      <span>${description}</span>
      <small>${time}</small>
    `;
    
    // Add to top of list
    activityList.insertBefore(item, activityList.firstChild);
    
    // Limit to 10 items
    const items = activityList.querySelectorAll('.activity-item');
    if (items.length > 10) {
      items[items.length - 1].remove();
    }
  }

  async refreshStats() {
    try {
      const status = await this.icpService.getStatus();
      this.updateSidebarStats(status);
    } catch (error) {
      console.error('Failed to refresh stats:', error);
    }
  }

  showWelcomeMessage() {
    if (!this.chat) return;
    
    // Welcome message is already in HTML, just ensure it's visible
    console.log('Agent Adam is ready to assist!');
  }

  showErrorMessage(message) {
    if (this.chat) {
      this.chat.addErrorMessage(message);
    } else {
      alert('Error: ' + message);
    }
  }

  autoResizeInput(input) {
    input.style.height = 'auto';
    input.style.height = Math.min(input.scrollHeight, 150) + 'px';
  }

  formatTimestamp(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now - date;
    
    if (diff < 60000) return 'Just now';
    if (diff < 3600000) return Math.floor(diff / 60000) + 'm ago';
    if (diff < 86400000) return Math.floor(diff / 3600000) + 'h ago';
    return date.toLocaleDateString();
  }

  cleanup() {
    console.log('Cleaning up Agent Adam...');
    // Cleanup code here if needed
  }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  window.agentAdam = new AgentAdamApp();
});

// Export for module use
export default AgentAdamApp;