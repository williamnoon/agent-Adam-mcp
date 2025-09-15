import Time "mo:base/Time";
import Result "mo:base/Result";

module Types {
    
    public type CommandSource = {
        #GHLWebhook: { webhookId: Text; eventType: Text };
        #GHLVoiceAgent: { sessionId: Text; callerId: Text };
        #GHLChatAgent: { conversationId: Text; contactId: Text };
        #AdminInterface: { userId: Text; locationId: Text };
    };

    public type CommandContext = {
        locationId: Text;
        sourceMetadata: ?Text;
        priority: Nat;
        retryCount: Nat;
    };

    public type Command = {
        id: Text;
        source: CommandSource;
        instruction: Text;
        context: CommandContext;
        timestamp: Time.Time;
    };

    public type ExecutionStatus = {
        #Pending;
        #Processing;
        #Completed;
        #Failed: { reason: Text };
        #PartialSuccess: { warnings: [Text] };
    };

    public type ExecutedAction = {
        actionType: Text;
        description: Text;
        result: Text;
        timestamp: Time.Time;
    };

    public type ExecutionResult = {
        commandId: Text;
        status: ExecutionStatus;
        actions: [ExecutedAction];
        insights: [Text];
        nextSteps: [Text];
        duration: Nat;
    };

    public type VoiceResponse = {
        spokenText: Text;
        actions: [Text];
        shouldEndCall: Bool;
        transferNumber: ?Text;
    };

    public type ChatResponse = {
        message: Text;
        quickReplies: [Text];
        attachments: [Text];
        shouldClose: Bool;
    };

    public type AdminResponse = {
        summary: Text;
        details: ExecutionResult;
        recommendedActions: [Text];
        alerts: [Text];
    };

    public type CommandInterpretation = {
        intent: Intent;
        entities: [Entity];
        confidence: Float;
        requiresApproval: Bool;
    };

    public type Intent = {
        #Create: { objectType: Text };
        #Update: { objectType: Text; identifier: Text };
        #Delete: { objectType: Text; identifier: Text };
        #Query: { objectType: Text; filters: [Text] };
        #Automation: { triggerType: Text; conditions: [Text] };
        #Unknown;
    };

    public type Entity = {
        entityType: Text;
        value: Text;
        confidence: Float;
    };

    public type UserPreference = {
        userId: Text;
        locationId: Text;
        preferences: [(Text, Text)];
        lastUpdated: Time.Time;
    };

}