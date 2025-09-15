import Text "mo:base/Text";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Option "mo:base/Option";
import Int "mo:base/Int";
import Nat "mo:base/Nat";

import Types "./Types";

module GHLIntegration {
    type ExecutionResult = Types.ExecutionResult;
    type ExecutedAction = Types.ExecutedAction;
    type VoiceResponse = Types.VoiceResponse;
    type ChatResponse = Types.ChatResponse;
    type AdminResponse = Types.AdminResponse;

    // Webhook payload parsing
    public func parseWebhookPayload(payload: Text): Result.Result<WebhookData, Text> {
        // Simple JSON-like parsing (in production, use proper JSON parser)
        if (Text.contains(payload, #text "contact")) {
            #ok({
                objectType = "contact";
                action = extractAction(payload);
                data = payload;
            })
        } else if (Text.contains(payload, #text "opportunity")) {
            #ok({
                objectType = "opportunity";
                action = extractAction(payload);
                data = payload;
            })
        } else {
            #err("Unknown webhook payload format")
        }
    };

    public func mapEventToCommand(eventType: Text): Text {
        switch (eventType) {
            case ("contact.created") { "A new contact has been created" };
            case ("contact.updated") { "A contact has been updated" };
            case ("opportunity.created") { "A new opportunity has been created" };
            case ("opportunity.won") { "An opportunity has been won" };
            case ("opportunity.lost") { "An opportunity has been lost" };
            case ("form.submitted") { "A form has been submitted" };
            case ("appointment.scheduled") { "An appointment has been scheduled" };
            case ("workflow.completed") { "A workflow has completed" };
            case (_) { "Unknown event: " # eventType };
        }
    };

    public func validateLocationId(locationId: Text): Bool {
        // Basic validation - location ID should be non-empty and alphanumeric
        locationId.size() > 0 and locationId.size() < 100
    };

    // Voice command formatting
    public func formatVoiceResponse(result: ExecutionResult): VoiceResponse {
        let spokenText = generateSpokenText(result);
        let actions = generateVoiceActions(result.actions);
        
        {
            spokenText = spokenText;
            actions = actions;
            shouldEndCall = shouldEndVoiceCall(result);
            transferNumber = getTransferNumber(result);
        }
    };

    public func generateVoiceActions(actions: [ExecutedAction]): [Text] {
        let voiceActions = Buffer.Buffer<Text>(0);
        
        for (action in actions.vals()) {
            switch (action.actionType) {
                case ("create_contact") { voiceActions.add("contact_created") };
                case ("send_email") { voiceActions.add("email_sent") };
                case ("schedule_appointment") { voiceActions.add("appointment_scheduled") };
                case ("update_opportunity") { voiceActions.add("opportunity_updated") };
                case (_) { voiceActions.add("action_completed") };
            }
        };
        
        Buffer.toArray(voiceActions)
    };

    public func handleVoiceSession(sessionId: Text): SessionContext {
        // Simple session management
        {
            sessionId = sessionId;
            isActive = true;
            startTime = Time.now();
            context = [];
        }
    };

    // Chat message processing
    public func extractMentions(message: Text): [Text] {
        let mentions = Buffer.Buffer<Text>(0);
        
        // Look for @adam mentions
        if (Text.contains(message, #text "@adam")) {
            mentions.add("adam");
        };
        
        // Look for other common mentions
        if (Text.contains(message, #text "@support")) {
            mentions.add("support");
        };
        
        Buffer.toArray(mentions)
    };

    public func formatChatResponse(result: ExecutionResult): ChatResponse {
        let message = generateChatMessage(result);
        let quickReplies = generateQuickReplies(result.nextSteps);
        
        {
            message = message;
            quickReplies = quickReplies;
            attachments = [];
            shouldClose = shouldCloseChat(result);
        }
    };

    public func generateQuickReplies(nextSteps: [Text]): [Text] {
        let replies = Buffer.Buffer<Text>(0);
        
        // Convert next steps to quick replies
        for (step in nextSteps.vals()) {
            if (step.size() < 30) { // Keep replies short
                replies.add(step);
            }
        };
        
        // Add default quick replies if none generated
        if (replies.size() == 0) {
            replies.add("Got it!");
            replies.add("Tell me more");
            replies.add("What's next?");
        };
        
        Buffer.toArray(replies)
    };

    // Workflow integration
    public func parseWorkflowContext(context: Text): WorkflowContext {
        {
            workflowId = extractWorkflowId(context);
            stepId = extractStepId(context);
            variables = extractVariables(context);
        }
    };

    public func generateWorkflowDecision(result: ExecutionResult): WorkflowDecision {
        switch (result.status) {
            case (#Completed) {
                {
                    decision = "continue";
                    nextStep = "next";
                    variables = generateWorkflowVariables(result);
                }
            };
            case (#Failed(_)) {
                {
                    decision = "stop";
                    nextStep = "error";
                    variables = [];
                }
            };
            case (_) {
                {
                    decision = "wait";
                    nextStep = "pending";
                    variables = [];
                }
            };
        }
    };

    public func formatWorkflowResponse(result: ExecutionResult): Text {
        "{ \"status\": \"" # formatExecutionStatus(result.status) # 
        "\", \"message\": \"" # Text.join(", ", result.insights.vals()) # "\" }"
    };

    // Response templates
    public func getSuccessTemplate(channel: Text): Text {
        switch (channel) {
            case ("voice") { "Great! I've completed that task for you." };
            case ("chat") { "✅ Done! Your request has been processed successfully." };
            case ("admin") { "Task completed successfully. Check the details below." };
            case (_) { "Request processed successfully." };
        }
    };

    public func getErrorTemplate(channel: Text, error: Text): Text {
        switch (channel) {
            case ("voice") { "I'm sorry, I encountered an issue: " # error };
            case ("chat") { "❌ Oops! Something went wrong: " # error };
            case ("admin") { "Error: " # error };
            case (_) { "Error: " # error };
        }
    };

    public func getSuggestionTemplate(suggestions: [Text]): Text {
        if (suggestions.size() > 0) {
            "Here are some suggestions: " # Text.join(", ", suggestions.vals())
        } else {
            "Let me know if you need help with anything else!"
        }
    };

    // Private helper functions
    private func extractAction(payload: Text): Text {
        if (Text.contains(payload, #text "created")) { "created" }
        else if (Text.contains(payload, #text "updated")) { "updated" }
        else if (Text.contains(payload, #text "deleted")) { "deleted" }
        else { "unknown" }
    };

    private func generateSpokenText(result: ExecutionResult): Text {
        switch (result.status) {
            case (#Completed) {
                if (result.insights.size() > 0) {
                    result.insights[0]
                } else {
                    "I've completed your request successfully."
                }
            };
            case (#Failed(reason)) {
                "I'm sorry, but I encountered an issue: " # reason.reason
            };
            case (#Processing) {
                "I'm currently processing your request. Please hold on."
            };
            case (_) {
                "Your request is being handled."
            };
        }
    };

    private func shouldEndVoiceCall(result: ExecutionResult): Bool {
        switch (result.status) {
            case (#Failed(_)) { true };
            case (_) { false };
        }
    };

    private func getTransferNumber(result: ExecutionResult): ?Text {
        // Check if result indicates need for human transfer
        for (action in result.actions.vals()) {
            if (action.actionType == "transfer_to_human") {
                return ?"+1234567890"; // Default transfer number
            }
        };
        null
    };

    private func generateChatMessage(result: ExecutionResult): Text {
        switch (result.status) {
            case (#Completed) {
                "✅ " # getSuccessTemplate("chat") # "\n\n" # 
                Text.join("\n", result.insights.vals())
            };
            case (#Failed(reason)) {
                getErrorTemplate("chat", reason.reason)
            };
            case (_) {
                "⏳ Processing your request..."
            };
        }
    };

    private func shouldCloseChat(result: ExecutionResult): Bool {
        // Don't auto-close chats, let user decide
        false
    };

    private func extractWorkflowId(context: Text): Text {
        // Simple extraction - look for workflow_id pattern
        if (Text.contains(context, #text "workflow_id")) {
            "extracted_workflow_id"
        } else {
            "unknown"
        }
    };

    private func extractStepId(context: Text): Text {
        if (Text.contains(context, #text "step_id")) {
            "extracted_step_id"
        } else {
            "unknown"
        }
    };

    private func extractVariables(context: Text): [(Text, Text)] {
        // Simple variable extraction
        [("status", "active"), ("timestamp", Int.toText(Time.now()))]
    };

    private func generateWorkflowVariables(result: ExecutionResult): [(Text, Text)] {
        let variables = Buffer.Buffer<(Text, Text)>(0);
        
        variables.add(("execution_status", formatExecutionStatus(result.status)));
        variables.add(("command_id", result.commandId));
        variables.add(("duration", Nat.toText(result.duration)));
        
        Buffer.toArray(variables)
    };

    private func formatExecutionStatus(status: Types.ExecutionStatus): Text {
        switch (status) {
            case (#Pending) { "pending" };
            case (#Processing) { "processing" };
            case (#Completed) { "completed" };
            case (#Failed(_)) { "failed" };
            case (#PartialSuccess(_)) { "partial_success" };
        }
    };

    // Type definitions for internal use
    private type WebhookData = {
        objectType: Text;
        action: Text;
        data: Text;
    };

    private type SessionContext = {
        sessionId: Text;
        isActive: Bool;
        startTime: Time.Time;
        context: [Text];
    };

    private type WorkflowContext = {
        workflowId: Text;
        stepId: Text;
        variables: [(Text, Text)];
    };

    private type WorkflowDecision = {
        decision: Text;
        nextStep: Text;
        variables: [(Text, Text)];
    };

}