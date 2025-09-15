/**
 * Demo ICP Service - Simulates ICP responses for testing without canister
 */

class DemoICPService {
  constructor() {
    this.isInitialized = false;
    this.commandHistory = [];
    this.totalCommands = 0;
  }

  /**
   * Initialize the demo service
   */
  async init() {
    // Simulate initialization delay
    await this.delay(1000);
    this.isInitialized = true;
    console.log('Demo ICP Service initialized successfully');
    return true;
  }

  /**
   * Process a natural language command (Demo version)
   */
  async processCommand(instruction, context = {}) {
    console.log('Demo: Processing command:', instruction);
    
    // Simulate processing delay
    await this.delay(1500);
    
    this.totalCommands++;
    
    // Create demo command
    const command = {
      id: `demo_cmd_${Date.now()}`,
      instruction: instruction,
      timestamp: new Date(),
      source: 'demo-interface'
    };
    
    this.commandHistory.unshift(command);
    if (this.commandHistory.length > 10) {
      this.commandHistory.pop();
    }
    
    // Generate intelligent demo response based on command content
    const response = this.generateDemoResponse(instruction);
    
    return response;
  }

  /**
   * Generate intelligent demo responses based on command content
   */
  generateDemoResponse(instruction) {
    const lowerInstruction = instruction.toLowerCase();
    
    // Contact creation pattern
    if (lowerInstruction.includes('create') && lowerInstruction.includes('contact')) {
      return this.generateContactResponse(instruction);
    }
    
    // Appointment/call scheduling pattern
    if (lowerInstruction.includes('appointment') || lowerInstruction.includes('discovery call') || lowerInstruction.includes('schedule')) {
      return this.generateAppointmentResponse(instruction);
    }
    
    // Lead magnet pattern
    if (lowerInstruction.includes('lead magnet') || lowerInstruction.includes('free')) {
      return this.generateLeadMagnetResponse(instruction);
    }
    
    // Workflow/automation pattern
    if (lowerInstruction.includes('workflow') || lowerInstruction.includes('automation')) {
      return this.generateWorkflowResponse(instruction);
    }
    
    // Default response
    return this.generateDefaultResponse(instruction);
  }

  generateContactResponse(instruction) {
    // Extract contact details from instruction
    const emailMatch = instruction.match(/[\w.-]+@[\w.-]+\.\w+/);
    const phoneMatch = instruction.match(/\b\d{3}[-.]?\d{3}[-.]?\d{4}\b/);
    const nameMatch = instruction.match(/(?:create.*contact:?\s*-?\s*|name:?\s*)([A-Z][a-z]+\s+[A-Z][a-z]+)/i);
    
    const email = emailMatch ? emailMatch[0] : 'email@example.com';
    const phone = phoneMatch ? phoneMatch[0] : '555-000-0000';
    const name = nameMatch ? nameMatch[1] : 'New Contact';
    
    return {
      commandId: `demo_${Date.now()}`,
      status: 'Completed',
      actions: [
        {
          actionType: 'create_contact',
          description: `Created new contact: ${name}`,
          result: `Contact ID: GHL_${Math.random().toString(36).substr(2, 9)}`,
          timestamp: Date.now()
        },
        {
          actionType: 'add_contact_info',
          description: `Added email: ${email}`,
          result: 'Email added successfully',
          timestamp: Date.now()
        },
        {
          actionType: 'add_contact_info', 
          description: `Added phone: ${phone}`,
          result: 'Phone added successfully',
          timestamp: Date.now()
        }
      ],
      insights: [
        `✅ **Contact Created Successfully!**`,
        `📧 **Email**: ${email}`,
        `📞 **Phone**: ${phone}`,
        `🏷️ **Tagged**: AI Consultation Interest`,
        `🎯 **Source**: Direct Input`
      ],
      nextSteps: [
        'Send lead magnet',
        'Schedule discovery call',
        'Add to nurture sequence'
      ],
      duration: 1200
    };
  }

  generateAppointmentResponse(instruction) {
    const timeSlots = [
      'Tomorrow at 2:00 PM',
      'Tuesday at 10:00 AM', 
      'Wednesday at 3:00 PM',
      'Thursday at 11:00 AM',
      'Friday at 1:00 PM'
    ];
    
    const selectedTime = timeSlots[Math.floor(Math.random() * timeSlots.length)];
    
    return {
      commandId: `demo_${Date.now()}`,
      status: 'Completed',
      actions: [
        {
          actionType: 'create_appointment',
          description: `Scheduled discovery call for ${selectedTime}`,
          result: `Calendar link sent via email`,
          timestamp: Date.now()
        },
        {
          actionType: 'send_notification',
          description: 'Sent confirmation email with calendar invite',
          result: 'Email delivered successfully',
          timestamp: Date.now()
        }
      ],
      insights: [
        `📅 **Discovery Call Scheduled**`,
        `⏰ **Time**: ${selectedTime}`,
        `📧 **Confirmation**: Email sent with calendar invite`,
        `🔗 **Zoom Link**: Included in calendar invite`,
        `⏰ **Reminder**: Set for 1 hour before`
      ],
      nextSteps: [
        'Prepare discovery call agenda',
        'Send pre-call questionnaire',
        'Review prospect background'
      ],
      duration: 800
    };
  }

  generateLeadMagnetResponse(instruction) {
    const leadMagnets = [
      'AI Strategy Consultation Checklist',
      'Complete Guide to AI Automation',
      'Free AI ROI Calculator',
      'AI Implementation Roadmap Template',
      '10 AI Tools Every Business Needs'
    ];
    
    const selectedMagnet = leadMagnets[Math.floor(Math.random() * leadMagnets.length)];
    
    return {
      commandId: `demo_${Date.now()}`,
      status: 'Completed',
      actions: [
        {
          actionType: 'send_lead_magnet',
          description: `Sent "${selectedMagnet}" via email`,
          result: 'Lead magnet delivered successfully',
          timestamp: Date.now()
        },
        {
          actionType: 'add_to_sequence',
          description: 'Added to AI consultation nurture sequence',
          result: 'Contact enrolled in 7-day email sequence',
          timestamp: Date.now()
        }
      ],
      insights: [
        `🎁 **Lead Magnet Sent**: ${selectedMagnet}`,
        `📬 **Delivery**: Email sent with download link`,
        `🔄 **Automation**: Added to nurture sequence`,
        `🎯 **Next Touch**: Follow-up in 24 hours`,
        `📊 **Tracking**: Opens and clicks being monitored`
      ],
      nextSteps: [
        'Monitor email engagement',
        'Follow up in 24-48 hours',
        'Schedule discovery call'
      ],
      duration: 950
    };
  }

  generateWorkflowResponse(instruction) {
    return {
      commandId: `demo_${Date.now()}`,
      status: 'Completed',
      actions: [
        {
          actionType: 'create_workflow',
          description: 'Created AI consultation workflow',
          result: 'Workflow activated with 5 steps',
          timestamp: Date.now()
        }
      ],
      insights: [
        `⚡ **Workflow Created**: AI Consultation Pipeline`,
        `📋 **Steps**: 5-step automated sequence`,
        `🎯 **Triggers**: New contact with AI interest tag`,
        `📧 **Includes**: Welcome email, lead magnet, follow-ups`,
        `📞 **Outcome**: Scheduled discovery call`
      ],
      nextSteps: [
        'Test workflow with sample contact',
        'Monitor automation performance',
        'Optimize based on results'
      ],
      duration: 1100
    };
  }

  generateDefaultResponse(instruction) {
    return {
      commandId: `demo_${Date.now()}`,
      status: 'Completed',
      actions: [
        {
          actionType: 'process_request',
          description: 'Analyzed and processed your request',
          result: 'Request understood and executed',
          timestamp: Date.now()
        }
      ],
      insights: [
        `🤖 **Agent Adam processed your request**`,
        `📝 **Command**: "${instruction.substring(0, 50)}${instruction.length > 50 ? '...' : ''}"`,
        `✅ **Status**: Successfully completed`,
        `🕐 **Processed**: ${new Date().toLocaleTimeString()}`
      ],
      nextSteps: [
        'Review the results',
        'Provide additional details if needed',
        'Ask follow-up questions'
      ],
      duration: 750
    };
  }

  /**
   * Get command history
   */
  async getHistory(limit = 10) {
    await this.delay(200);
    return this.commandHistory.slice(0, limit);
  }

  /**
   * Get service status
   */
  async getStatus() {
    await this.delay(100);
    return {
      status: 'Agent Adam Demo Mode - Fully Operational',
      totalCommands: this.totalCommands,
      isOnline: true,
      mode: 'demo',
      lastCheck: new Date().toISOString()
    };
  }

  /**
   * Utility function for delays
   */
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Format timestamp for display
   */
  formatTimestamp(timestamp) {
    return new Date(timestamp).toLocaleTimeString();
  }
}

// Create and export singleton instance
const demoICPService = new DemoICPService();

export default demoICPService;