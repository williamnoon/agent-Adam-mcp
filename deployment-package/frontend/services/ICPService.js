/**
 * ICPService - Interface to communicate with the Agent Adam Motoko canister
 * Handles all ICP blockchain interactions and canister communication
 */

import { Actor, HttpAgent } from "@dfinity/agent";
import { Principal } from "@dfinity/principal";

// Development canister ID (will be replaced with actual ID after deployment)
const CANISTER_ID = "rrkah-fqaaa-aaaah-qcuwa-cai";

// Candid interface definition for the Agent Adam canister
const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  
  const CommandSource = IDL.Variant({
    'GHLWebhook': IDL.Record({ 'webhookId': IDL.Text, 'eventType': IDL.Text }),
    'GHLVoiceAgent': IDL.Record({ 'sessionId': IDL.Text, 'callerId': IDL.Text }),
    'GHLChatAgent': IDL.Record({ 'conversationId': IDL.Text, 'contactId': IDL.Text }),
    'AdminInterface': IDL.Record({ 'userId': IDL.Text, 'locationId': IDL.Text })
  });

  const CommandContext = IDL.Record({
    'locationId': IDL.Text,
    'sourceMetadata': IDL.Opt(IDL.Text),
    'priority': IDL.Nat,
    'retryCount': IDL.Nat
  });

  const Command = IDL.Record({
    'id': IDL.Text,
    'source': CommandSource,
    'instruction': IDL.Text,
    'context': CommandContext,
    'timestamp': Time
  });

  const ExecutionStatus = IDL.Variant({
    'Pending': IDL.Null,
    'Processing': IDL.Null,
    'Completed': IDL.Null,
    'Failed': IDL.Record({ 'reason': IDL.Text }),
    'PartialSuccess': IDL.Record({ 'warnings': IDL.Vec(IDL.Text) })
  });

  const ExecutedAction = IDL.Record({
    'actionType': IDL.Text,
    'description': IDL.Text,
    'result': IDL.Text,
    'timestamp': Time
  });

  const ExecutionResult = IDL.Record({
    'commandId': IDL.Text,
    'status': ExecutionStatus,
    'actions': IDL.Vec(ExecutedAction),
    'insights': IDL.Vec(IDL.Text),
    'nextSteps': IDL.Vec(IDL.Text),
    'duration': IDL.Nat
  });

  const VoiceResponse = IDL.Record({
    'spokenText': IDL.Text,
    'actions': IDL.Vec(IDL.Text),
    'shouldEndCall': IDL.Bool,
    'transferNumber': IDL.Opt(IDL.Text)
  });

  const ChatResponse = IDL.Record({
    'message': IDL.Text,
    'quickReplies': IDL.Vec(IDL.Text),
    'attachments': IDL.Vec(IDL.Text),
    'shouldClose': IDL.Bool
  });

  const AdminResponse = IDL.Record({
    'summary': IDL.Text,
    'details': ExecutionResult,
    'recommendedActions': IDL.Vec(IDL.Text),
    'alerts': IDL.Vec(IDL.Text)
  });

  const Result = (ok, err) => IDL.Variant({ 'ok': ok, 'err': err });

  return IDL.Service({
    'processCommand': IDL.Func([Command], [Result(ExecutionResult, IDL.Text)], []),
    'handleWebhook': IDL.Func([IDL.Text, IDL.Text, IDL.Text, IDL.Text], [Result(IDL.Text, IDL.Text)], []),
    'processVoiceCommand': IDL.Func([IDL.Text, IDL.Text, IDL.Text, IDL.Text], [Result(VoiceResponse, IDL.Text)], []),
    'processChatCommand': IDL.Func([IDL.Text, IDL.Text, IDL.Text, IDL.Text], [Result(ChatResponse, IDL.Text)], []),
    'processAdminCommand': IDL.Func([IDL.Text, IDL.Text, IDL.Text], [Result(AdminResponse, IDL.Text)], []),
    'getCommandHistory': IDL.Func([IDL.Nat], [IDL.Vec(Command)], ['query']),
    'getExecutionResult': IDL.Func([IDL.Text], [IDL.Opt(ExecutionResult)], ['query']),
    'getTotalCommands': IDL.Func([], [IDL.Nat], ['query']),
    'getCanisterStatus': IDL.Func([], [IDL.Text], ['query'])
  });
};

class ICPService {
  constructor(canisterId = CANISTER_ID, options = {}) {
    this.canisterId = canisterId;
    this.options = options;
    this.agent = null;
    this.actor = null;
    this.isInitialized = false;
    this.retryAttempts = 3;
    this.retryDelay = 1000; // 1 second
  }

  /**
   * Initialize the ICP agent and actor
   * @returns {Promise<boolean>} Success status
   */
  async init() {
    try {
      // Create HTTP agent
      const host = this.options.host || "https://ic0.app";
      this.agent = new HttpAgent({ 
        host,
        ...this.options 
      });

      // Fetch root key for local development
      if (host.includes("localhost") || host.includes("127.0.0.1")) {
        await this.agent.fetchRootKey();
      }

      // Create actor
      this.actor = Actor.createActor(idlFactory, {
        agent: this.agent,
        canisterId: this.canisterId,
      });

      this.isInitialized = true;
      console.log("ICP Service initialized successfully");
      return true;
    } catch (error) {
      console.error("Failed to initialize ICP Service:", error);
      this.isInitialized = false;
      return false;
    }
  }

  /**
   * Process a natural language command
   * @param {string} instruction - The natural language instruction
   * @param {Object} context - Command context
   * @returns {Promise<Object>} Execution result or error
   */
  async processCommand(instruction, context = {}) {
    if (!this.isInitialized) {
      await this.init();
    }

    const command = {
      id: this.generateCommandId(),
      source: { AdminInterface: { userId: "web-user", locationId: context.locationId || "default" } },
      instruction: instruction,
      context: {
        locationId: context.locationId || "default",
        sourceMetadata: [context.source || "web-interface"],
        priority: context.priority || 1,
        retryCount: 0
      },
      timestamp: BigInt(Date.now() * 1000000) // Convert to nanoseconds
    };

    return this.withRetry(async () => {
      const result = await this.actor.processCommand(command);
      return this.handleResult(result, "Failed to process command");
    });
  }

  /**
   * Get command history
   * @param {number} limit - Maximum number of commands to retrieve
   * @returns {Promise<Array>} Array of commands
   */
  async getHistory(limit = 10) {
    if (!this.isInitialized) {
      await this.init();
    }

    return this.withRetry(async () => {
      const commands = await this.actor.getCommandHistory(limit);
      return commands.map(this.formatCommand);
    });
  }

  /**
   * Check canister status
   * @returns {Promise<Object>} Status information
   */
  async getStatus() {
    if (!this.isInitialized) {
      await this.init();
    }

    return this.withRetry(async () => {
      const [status, totalCommands] = await Promise.all([
        this.actor.getCanisterStatus(),
        this.actor.getTotalCommands()
      ]);

      return {
        status: status,
        totalCommands: Number(totalCommands),
        isOnline: true,
        lastCheck: new Date().toISOString()
      };
    });
  }

  /**
   * Process webhook from GoHighLevel
   * @param {string} webhookId - Webhook identifier
   * @param {string} eventType - Type of webhook event
   * @param {string} payload - Webhook payload
   * @param {string} locationId - GHL location ID
   * @returns {Promise<Object>} Processing result
   */
  async handleWebhook(webhookId, eventType, payload, locationId) {
    if (!this.isInitialized) {
      await this.init();
    }

    return this.withRetry(async () => {
      const result = await this.actor.handleWebhook(webhookId, eventType, payload, locationId);
      return this.handleResult(result, "Failed to handle webhook");
    });
  }

  /**
   * Process voice command
   * @param {string} sessionId - Voice session ID
   * @param {string} callerId - Caller identifier
   * @param {string} transcript - Voice transcript
   * @param {string} locationId - GHL location ID
   * @returns {Promise<Object>} Voice response
   */
  async processVoiceCommand(sessionId, callerId, transcript, locationId) {
    if (!this.isInitialized) {
      await this.init();
    }

    return this.withRetry(async () => {
      const result = await this.actor.processVoiceCommand(sessionId, callerId, transcript, locationId);
      return this.handleResult(result, "Failed to process voice command");
    });
  }

  /**
   * Process chat command
   * @param {string} conversationId - Chat conversation ID
   * @param {string} contactId - Contact identifier
   * @param {string} message - Chat message
   * @param {string} locationId - GHL location ID
   * @returns {Promise<Object>} Chat response
   */
  async processChatCommand(conversationId, contactId, message, locationId) {
    if (!this.isInitialized) {
      await this.init();
    }

    return this.withRetry(async () => {
      const result = await this.actor.processChatCommand(conversationId, contactId, message, locationId);
      return this.handleResult(result, "Failed to process chat command");
    });
  }

  /**
   * Execute function with retry logic
   * @param {Function} fn - Function to execute
   * @returns {Promise<any>} Function result
   */
  async withRetry(fn) {
    let lastError;
    
    for (let attempt = 1; attempt <= this.retryAttempts; attempt++) {
      try {
        return await fn();
      } catch (error) {
        lastError = error;
        console.warn(`Attempt ${attempt} failed:`, error.message);
        
        if (attempt < this.retryAttempts) {
          await this.delay(this.retryDelay * attempt);
          
          // Re-initialize if connection seems lost
          if (error.message.includes("fetch") || error.message.includes("network")) {
            await this.init();
          }
        }
      }
    }
    
    throw new Error(`Failed after ${this.retryAttempts} attempts: ${lastError.message}`);
  }

  /**
   * Handle Result type from Motoko
   * @param {Object} result - Result from canister
   * @param {string} errorMessage - Default error message
   * @returns {any} Unwrapped result
   */
  handleResult(result, errorMessage) {
    if ('ok' in result) {
      return result.ok;
    } else if ('err' in result) {
      throw new Error(result.err);
    } else {
      throw new Error(errorMessage);
    }
  }

  /**
   * Format command for frontend consumption
   * @param {Object} command - Raw command from canister
   * @returns {Object} Formatted command
   */
  formatCommand(command) {
    return {
      id: command.id,
      instruction: command.instruction,
      source: this.formatSource(command.source),
      context: command.context,
      timestamp: new Date(Number(command.timestamp) / 1000000), // Convert from nanoseconds
    };
  }

  /**
   * Format command source for display
   * @param {Object} source - Command source variant
   * @returns {string} Formatted source
   */
  formatSource(source) {
    if ('GHLWebhook' in source) return `Webhook: ${source.GHLWebhook.eventType}`;
    if ('GHLVoiceAgent' in source) return `Voice: ${source.GHLVoiceAgent.sessionId}`;
    if ('GHLChatAgent' in source) return `Chat: ${source.GHLChatAgent.conversationId}`;
    if ('AdminInterface' in source) return `Admin: ${source.AdminInterface.userId}`;
    return 'Unknown';
  }

  /**
   * Generate unique command ID
   * @returns {string} Unique identifier
   */
  generateCommandId() {
    return `cmd_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Utility function for delays
   * @param {number} ms - Milliseconds to delay
   * @returns {Promise<void>}
   */
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Create and export singleton instance
const icpService = new ICPService();

export default icpService;