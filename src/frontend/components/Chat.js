/**
 * Chat Component - Handles the chat interface for Agent Adam
 * Manages message display, user input, and real-time communication
 */

class Chat {
  constructor(containerElement) {
    this.container = containerElement;
    this.messagesContainer = containerElement.querySelector('#messages');
    this.isAtBottom = true;
    this.messageIdCounter = 0;
    this.typingIndicatorId = null;
    
    this.init();
  }

  /**
   * Initialize the chat component
   */
  init() {
    if (!this.messagesContainer) {
      console.error('Messages container not found');
      return;
    }

    // Listen for scroll events to track position
    this.messagesContainer.addEventListener('scroll', () => {
      this.updateScrollPosition();
    });

    // Add resize observer to handle container changes
    if (window.ResizeObserver) {
      const resizeObserver = new ResizeObserver(() => {
        if (this.isAtBottom) {
          this.scrollToBottom();
        }
      });
      resizeObserver.observe(this.messagesContainer);
    }
  }

  /**
   * Render a new message in the chat
   * @param {string} message - The message content
   * @param {string} sender - The sender ('user' or 'adam')
   * @param {Date|string} timestamp - Message timestamp
   * @param {Object} options - Additional options
   * @returns {HTMLElement} The created message element
   */
  renderMessage(message, sender = 'adam', timestamp = new Date(), options = {}) {
    const messageElement = document.createElement('div');
    const messageId = `msg-${++this.messageIdCounter}`;
    
    messageElement.id = messageId;
    messageElement.className = `message message-${sender}`;
    
    // Create message content
    const contentElement = document.createElement('div');
    contentElement.className = 'message-content';
    
    // Support markdown-like formatting
    const formattedMessage = this.formatMessage(message);
    contentElement.innerHTML = formattedMessage;
    
    // Create timestamp
    const timeElement = document.createElement('div');
    timeElement.className = 'message-time';
    timeElement.textContent = this.formatTimestamp(timestamp);
    
    // Assemble message
    messageElement.appendChild(contentElement);
    messageElement.appendChild(timeElement);
    
    // Add delivery status if specified
    if (options.status) {
      const statusElement = document.createElement('div');
      statusElement.className = `message-status status-${options.status}`;
      statusElement.textContent = this.getStatusText(options.status);
      messageElement.appendChild(statusElement);
    }
    
    // Add to messages container
    this.messagesContainer.appendChild(messageElement);
    
    // Handle quick replies
    if (options.quickReplies && options.quickReplies.length > 0) {
      this.renderQuickReplies(options.quickReplies, messageId);
    }
    
    // Auto-scroll if at bottom
    if (this.isAtBottom) {
      this.scrollToBottom();
    }
    
    // Add entrance animation
    this.animateMessageEntrance(messageElement);
    
    return messageElement;
  }

  /**
   * Format message content with basic markdown support
   * @param {string} message - Raw message
   * @returns {string} Formatted HTML
   */
  formatMessage(message) {
    return message
      // Bold text
      .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
      // Italic text
      .replace(/\*(.*?)\*/g, '<em>$1</em>')
      // Code blocks
      .replace(/```(.*?)```/gs, '<pre><code>$1</code></pre>')
      // Inline code
      .replace(/`(.*?)`/g, '<code>$1</code>')
      // Line breaks
      .replace(/\n/g, '<br>')
      // Links
      .replace(/(https?:\/\/[^\s]+)/g, '<a href="$1" target="_blank" rel="noopener">$1</a>')
      // Email addresses
      .replace(/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/g, '<a href="mailto:$1">$1</a>');
  }

  /**
   * Render quick reply buttons
   * @param {Array<string>} replies - Quick reply options
   * @param {string} messageId - Associated message ID
   */
  renderQuickReplies(replies, messageId) {
    const quickRepliesContainer = document.createElement('div');
    quickRepliesContainer.className = 'quick-replies';
    quickRepliesContainer.setAttribute('data-message-id', messageId);
    
    replies.forEach((reply, index) => {
      const button = document.createElement('button');
      button.className = 'quick-reply-button';
      button.textContent = reply;
      button.setAttribute('data-reply', reply);
      
      // Add click handler
      button.addEventListener('click', (e) => {
        this.handleQuickReply(reply, e.target);
      });
      
      quickRepliesContainer.appendChild(button);
    });
    
    this.messagesContainer.appendChild(quickRepliesContainer);
    
    if (this.isAtBottom) {
      this.scrollToBottom();
    }
  }

  /**
   * Handle quick reply selection
   * @param {string} reply - Selected reply text
   * @param {HTMLElement} buttonElement - Clicked button
   */
  handleQuickReply(reply, buttonElement) {
    // Disable all quick reply buttons
    const container = buttonElement.closest('.quick-replies');
    const buttons = container.querySelectorAll('.quick-reply-button');
    buttons.forEach(btn => {
      btn.disabled = true;
      btn.classList.add('disabled');
    });
    
    // Highlight selected button
    buttonElement.classList.add('selected');
    
    // Trigger quick reply event
    this.container.dispatchEvent(new CustomEvent('quickReply', {
      detail: { reply, messageId: container.getAttribute('data-message-id') }
    }));
  }

  /**
   * Clear all messages from the chat
   */
  clearMessages() {
    this.messagesContainer.innerHTML = '';
    this.messageIdCounter = 0;
    this.hideTypingIndicator();
  }

  /**
   * Scroll to bottom of messages
   * @param {boolean} smooth - Use smooth scrolling
   */
  scrollToBottom(smooth = true) {
    const scrollOptions = {
      top: this.messagesContainer.scrollHeight,
      behavior: smooth ? 'smooth' : 'auto'
    };
    
    this.messagesContainer.scrollTo(scrollOptions);
    this.isAtBottom = true;
  }

  /**
   * Show typing indicator
   * @param {string} sender - Who is typing (default: 'adam')
   */
  showTypingIndicator(sender = 'adam') {
    this.hideTypingIndicator(); // Remove existing indicator
    
    const indicator = document.createElement('div');
    indicator.className = `typing-indicator typing-${sender}`;
    indicator.id = 'typing-indicator';
    
    const dots = document.createElement('div');
    dots.className = 'typing-dots';
    dots.innerHTML = '<span></span><span></span><span></span>';
    
    const label = document.createElement('div');
    label.className = 'typing-label';
    label.textContent = sender === 'adam' ? 'Agent Adam is thinking...' : 'User is typing...';
    
    indicator.appendChild(dots);
    indicator.appendChild(label);
    
    this.messagesContainer.appendChild(indicator);
    this.typingIndicatorId = indicator.id;
    
    if (this.isAtBottom) {
      this.scrollToBottom();
    }
  }

  /**
   * Hide typing indicator
   */
  hideTypingIndicator() {
    if (this.typingIndicatorId) {
      const indicator = document.getElementById(this.typingIndicatorId);
      if (indicator) {
        indicator.remove();
      }
      this.typingIndicatorId = null;
    }
  }

  /**
   * Update message status
   * @param {string} messageId - Message ID
   * @param {string} status - New status ('sending', 'delivered', 'error')
   */
  updateMessageStatus(messageId, status) {
    const messageElement = document.getElementById(messageId);
    if (!messageElement) return;
    
    let statusElement = messageElement.querySelector('.message-status');
    if (!statusElement) {
      statusElement = document.createElement('div');
      statusElement.className = 'message-status';
      messageElement.appendChild(statusElement);
    }
    
    statusElement.className = `message-status status-${status}`;
    statusElement.textContent = this.getStatusText(status);
  }

  /**
   * Add error message
   * @param {string} error - Error message
   * @param {string} context - Error context
   */
  addErrorMessage(error, context = '') {
    const errorMessage = `❌ ${error}${context ? ` (${context})` : ''}`;
    this.renderMessage(errorMessage, 'system', new Date(), {
      status: 'error'
    });
  }

  /**
   * Add system message
   * @param {string} message - System message
   * @param {string} type - Message type ('info', 'warning', 'success')
   */
  addSystemMessage(message, type = 'info') {
    const icons = {
      info: 'ℹ️',
      warning: '⚠️',
      success: '✅',
      error: '❌'
    };
    
    const systemMessage = `${icons[type] || icons.info} ${message}`;
    this.renderMessage(systemMessage, 'system', new Date());
  }

  /**
   * Get the last message element
   * @returns {HTMLElement|null} Last message element
   */
  getLastMessage() {
    const messages = this.messagesContainer.querySelectorAll('.message');
    return messages[messages.length - 1] || null;
  }

  /**
   * Get message count
   * @returns {number} Number of messages
   */
  getMessageCount() {
    return this.messagesContainer.querySelectorAll('.message').length;
  }

  // Private helper methods

  /**
   * Update scroll position tracking
   */
  updateScrollPosition() {
    const container = this.messagesContainer;
    const threshold = 50; // pixels from bottom
    
    this.isAtBottom = (
      container.scrollTop + container.clientHeight >= 
      container.scrollHeight - threshold
    );
  }

  /**
   * Format timestamp for display
   * @param {Date|string} timestamp - Timestamp to format
   * @returns {string} Formatted time
   */
  formatTimestamp(timestamp) {
    const date = timestamp instanceof Date ? timestamp : new Date(timestamp);
    const now = new Date();
    const diff = now - date;
    
    // Less than 1 minute
    if (diff < 60000) {
      return 'Just now';
    }
    
    // Less than 1 hour
    if (diff < 3600000) {
      const minutes = Math.floor(diff / 60000);
      return `${minutes}m ago`;
    }
    
    // Less than 24 hours
    if (diff < 86400000) {
      const hours = Math.floor(diff / 3600000);
      return `${hours}h ago`;
    }
    
    // More than 24 hours
    return date.toLocaleDateString();
  }

  /**
   * Get status text for display
   * @param {string} status - Status code
   * @returns {string} Display text
   */
  getStatusText(status) {
    const statusTexts = {
      sending: 'Sending...',
      delivered: 'Delivered',
      error: 'Failed to send',
      processing: 'Processing...'
    };
    
    return statusTexts[status] || status;
  }

  /**
   * Animate message entrance
   * @param {HTMLElement} element - Message element
   */
  animateMessageEntrance(element) {
    element.style.opacity = '0';
    element.style.transform = 'translateY(20px)';
    
    // Trigger animation
    requestAnimationFrame(() => {
      element.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
      element.style.opacity = '1';
      element.style.transform = 'translateY(0)';
    });
  }
}

export default Chat;