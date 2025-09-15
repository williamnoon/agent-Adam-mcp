import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Int "mo:base/Int";

import Types "./Types";

actor persistent AgentAdam {
    type Command = Types.Command;
    type ExecutionResult = Types.ExecutionResult;
    type VoiceResponse = Types.VoiceResponse;
    type ChatResponse = Types.ChatResponse;
    type AdminResponse = Types.AdminResponse;
    type UserPreference = Types.UserPreference;
    type ExecutionStatus = Types.ExecutionStatus;

    // Stable variables for persistence
    private stable var commandHistory: [(Text, Command)] = [];
    private stable var executionResults: [(Text, ExecutionResult)] = [];
    private stable var userPreferences: [(Text, UserPreference)] = [];

    // Runtime state with HashMaps (marked as transient)
    private transient var commands = HashMap.HashMap<Text, Command>(10, Text.equal, Text.hash);
    private transient var results = HashMap.HashMap<Text, ExecutionResult>(10, Text.equal, Text.hash);
    private transient var preferences = HashMap.HashMap<Text, UserPreference>(10, Text.equal, Text.hash);

    // System upgrade hooks
    system func preupgrade() {
        commandHistory := Iter.toArray(commands.entries());
        executionResults := Iter.toArray(results.entries());
        userPreferences := Iter.toArray(preferences.entries());
    };

    system func postupgrade() {
        commands := HashMap.fromIter<Text, Command>(
            commandHistory.vals(), 10, Text.equal, Text.hash
        );
        results := HashMap.fromIter<Text, ExecutionResult>(
            executionResults.vals(), 10, Text.equal, Text.hash
        );
        preferences := HashMap.fromIter<Text, UserPreference>(
            userPreferences.vals(), 10, Text.equal, Text.hash
        );
        
        commandHistory := [];
        executionResults := [];
        userPreferences := [];
    };

    // Public shared functions
    public shared func processCommand(cmd: Command): async Result.Result<ExecutionResult, Text> {
        commands.put(cmd.id, cmd);
        
        let result: ExecutionResult = {
            commandId = cmd.id;
            status = #Completed;
            actions = [];
            insights = ["Command processed successfully"];
            nextSteps = ["Review execution result"];
            duration = 100;
        };
        
        results.put(cmd.id, result);
        #ok(result)
    };

    public shared func handleWebhook(
        webhookId: Text, 
        eventType: Text, 
        payload: Text, 
        locationId: Text
    ): async Result.Result<Text, Text> {
        let commandId = webhookId # "_" # Int.toText(Time.now());
        let command: Command = {
            id = commandId;
            source = #GHLWebhook({ webhookId; eventType });
            instruction = payload;
            context = {
                locationId;
                sourceMetadata = ?eventType;
                priority = 1;
                retryCount = 0;
            };
            timestamp = Time.now();
        };
        
        switch (await processCommand(command)) {
            case (#ok(_)) { #ok("Webhook processed successfully") };
            case (#err(msg)) { #err(msg) };
        }
    };

    public shared func processVoiceCommand(
        sessionId: Text,
        callerId: Text,
        transcript: Text,
        locationId: Text
    ): async Result.Result<VoiceResponse, Text> {
        let commandId = sessionId # "_" # Int.toText(Time.now());
        let command: Command = {
            id = commandId;
            source = #GHLVoiceAgent({ sessionId; callerId });
            instruction = transcript;
            context = {
                locationId;
                sourceMetadata = ?callerId;
                priority = 2;
                retryCount = 0;
            };
            timestamp = Time.now();
        };
        
        switch (await processCommand(command)) {
            case (#ok(result)) {
                let response: VoiceResponse = {
                    spokenText = "I've processed your request successfully.";
                    actions = ["confirm_action"];
                    shouldEndCall = false;
                    transferNumber = null;
                };
                #ok(response)
            };
            case (#err(msg)) { #err(msg) };
        }
    };

    public shared func processChatCommand(
        conversationId: Text,
        contactId: Text,
        message: Text,
        locationId: Text
    ): async Result.Result<ChatResponse, Text> {
        let commandId = conversationId # "_" # Int.toText(Time.now());
        let command: Command = {
            id = commandId;
            source = #GHLChatAgent({ conversationId; contactId });
            instruction = message;
            context = {
                locationId;
                sourceMetadata = ?contactId;
                priority = 2;
                retryCount = 0;
            };
            timestamp = Time.now();
        };
        
        switch (await processCommand(command)) {
            case (#ok(result)) {
                let response: ChatResponse = {
                    message = "I've processed your request. Here's what I found.";
                    quickReplies = ["Got it", "Tell me more", "What's next?"];
                    attachments = [];
                    shouldClose = false;
                };
                #ok(response)
            };
            case (#err(msg)) { #err(msg) };
        }
    };

    public shared func processAdminCommand(
        userId: Text,
        locationId: Text,
        instruction: Text
    ): async Result.Result<AdminResponse, Text> {
        let commandId = userId # "_" # Int.toText(Time.now());
        let command: Command = {
            id = commandId;
            source = #AdminInterface({ userId; locationId });
            instruction = instruction;
            context = {
                locationId;
                sourceMetadata = ?userId;
                priority = 3;
                retryCount = 0;
            };
            timestamp = Time.now();
        };
        
        switch (await processCommand(command)) {
            case (#ok(result)) {
                let response: AdminResponse = {
                    summary = "Command executed successfully";
                    details = result;
                    recommendedActions = ["Review results", "Monitor progress"];
                    alerts = [];
                };
                #ok(response)
            };
            case (#err(msg)) { #err(msg) };
        }
    };

    // Query functions
    public query func getCommandHistory(limit: Nat): async [Command] {
        let buffer = Buffer.Buffer<Command>(limit);
        var count = 0;
        
        for ((_, command) in commands.entries()) {
            if (count < limit) {
                buffer.add(command);
                count += 1;
            }
        };
        
        Buffer.toArray(buffer)
    };

    public query func getExecutionResult(commandId: Text): async ?ExecutionResult {
        results.get(commandId)
    };

    public query func getTotalCommands(): async Nat {
        commands.size()
    };

    public query func getCanisterStatus(): async Text {
        "Agent Adam is online and ready to process commands"
    };

}