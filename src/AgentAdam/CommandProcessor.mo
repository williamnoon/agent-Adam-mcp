import Text "mo:base/Text";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Float "mo:base/Float";
import Iter "mo:base/Iter";

import Types "./Types";

module CommandProcessor {
    type CommandInterpretation = Types.CommandInterpretation;
    type Intent = Types.Intent;
    type Entity = Types.Entity;
    type CommandContext = Types.CommandContext;

    // Common stop words to filter out
    private let stopWords = [
        "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", 
        "of", "with", "by", "from", "up", "about", "into", "through", "during",
        "before", "after", "above", "below", "between", "among", "is", "are", 
        "was", "were", "be", "been", "being", "have", "has", "had", "do", "does", 
        "did", "will", "would", "could", "should", "may", "might", "must", "can"
    ];

    // GHL entity types
    private let ghlEntities = [
        "contact", "lead", "opportunity", "pipeline", "workflow", "campaign", 
        "appointment", "calendar", "form", "funnel", "website", "automation",
        "tag", "trigger", "action", "email", "sms", "call", "task", "note",
        "invoice", "payment", "subscription", "location", "user", "agency"
    ];

    // Intent keywords mapping
    private let createKeywords = ["create", "build", "make", "add", "new", "generate", "setup", "start"];
    private let updateKeywords = ["update", "modify", "change", "edit", "revise", "alter", "adjust"];
    private let deleteKeywords = ["delete", "remove", "cancel", "stop", "end", "terminate", "clear"];
    private let queryKeywords = ["show", "get", "list", "find", "search", "view", "display", "check"];
    private let automationKeywords = ["automate", "trigger", "activate", "schedule", "set", "configure"];

    public func interpretCommand(instruction: Text, context: CommandContext): CommandInterpretation {
        let words = extractKeywords(instruction);
        let intent = detectIntent(words, instruction);
        let entities = extractEntities(words, instruction);
        let confidence = calculateConfidence(intent, entities, words);
        let requiresApproval = shouldRequireApproval(intent, context);

        {
            intent = intent;
            entities = entities;
            confidence = confidence;
            requiresApproval = requiresApproval;
        }
    };

    private func extractKeywords(instruction: Text): [Text] {
        let words = Text.split(Text.toLowercase(instruction), #char ' ');
        let filtered = Buffer.Buffer<Text>(0);
        
        for (word in words) {
            let cleanWord = Text.trim(word, #char ' ');
            if (cleanWord.size() > 2 and not isStopWord(cleanWord)) {
                filtered.add(cleanWord);
            };
        };
        
        Buffer.toArray(filtered)
    };

    private func isStopWord(word: Text): Bool {
        Array.find<Text>(stopWords, func(stopWord) = stopWord == word) != null
    };

    private func detectIntent(words: [Text], instruction: Text): Intent {
        let lowerInstruction = Text.toLowercase(instruction);
        
        // Check for create intent
        if (hasAnyKeyword(words, createKeywords)) {
            let objectType = findGHLEntity(words);
            return #Create({ objectType = objectType });
        };
        
        // Check for update intent
        if (hasAnyKeyword(words, updateKeywords)) {
            let objectType = findGHLEntity(words);
            let identifier = extractIdentifier(lowerInstruction);
            return #Update({ objectType = objectType; identifier = identifier });
        };
        
        // Check for delete intent
        if (hasAnyKeyword(words, deleteKeywords)) {
            let objectType = findGHLEntity(words);
            let identifier = extractIdentifier(lowerInstruction);
            return #Delete({ objectType = objectType; identifier = identifier });
        };
        
        // Check for query intent
        if (hasAnyKeyword(words, queryKeywords)) {
            let objectType = findGHLEntity(words);
            let filters = extractFilters(words);
            return #Query({ objectType = objectType; filters = filters });
        };
        
        // Check for automation intent
        if (hasAnyKeyword(words, automationKeywords)) {
            let triggerType = findTriggerType(words);
            let conditions = extractConditions(lowerInstruction);
            return #Automation({ triggerType = triggerType; conditions = conditions });
        };
        
        #Unknown
    };

    private func hasAnyKeyword(words: [Text], keywords: [Text]): Bool {
        Array.find<Text>(words, func(word) {
            Array.find<Text>(keywords, func(keyword) = keyword == word) != null
        }) != null
    };

    private func findGHLEntity(words: [Text]): Text {
        switch (Array.find<Text>(words, func(word) {
            Array.find<Text>(ghlEntities, func(entity) = entity == word) != null
        })) {
            case (?entity) { entity };
            case null { "unknown" };
        }
    };

    private func extractIdentifier(instruction: Text): Text {
        // Simple extraction - look for quoted strings or common ID patterns
        if (Text.contains(instruction, #text "\"")) {
            // Extract quoted content
            "quoted_identifier"
        } else if (Text.contains(instruction, #text "id:")) {
            // Extract ID after "id:"
            "extracted_id"
        } else {
            "auto_detected"
        }
    };

    private func extractFilters(words: [Text]): [Text] {
        let filters = Buffer.Buffer<Text>(0);
        
        // Look for common filter words
        let filterWords = ["today", "yesterday", "week", "month", "active", "inactive", "new", "old"];
        
        for (word in words.vals()) {
            if (Array.find<Text>(filterWords, func(filter) = filter == word) != null) {
                filters.add(word);
            };
        };
        
        Buffer.toArray(filters)
    };

    private func findTriggerType(words: [Text]): Text {
        let triggerTypes = ["email", "form", "webhook", "schedule", "tag", "status"];
        
        switch (Array.find<Text>(words, func(word) {
            Array.find<Text>(triggerTypes, func(trigger) = trigger == word) != null
        })) {
            case (?trigger) { trigger };
            case null { "manual" };
        }
    };

    private func extractConditions(instruction: Text): [Text] {
        let conditions = Buffer.Buffer<Text>(0);
        
        // Look for condition keywords
        if (Text.contains(instruction, #text "when")) {
            conditions.add("conditional");
        };
        if (Text.contains(instruction, #text "if")) {
            conditions.add("conditional");
        };
        if (Text.contains(instruction, #text "after")) {
            conditions.add("temporal");
        };
        if (Text.contains(instruction, #text "before")) {
            conditions.add("temporal");
        };
        
        Buffer.toArray(conditions)
    };

    private func extractEntities(words: [Text], instruction: Text): [Entity] {
        let entities = Buffer.Buffer<Entity>(0);
        
        // Extract GHL entities
        for (word in words.vals()) {
            if (Array.find<Text>(ghlEntities, func(entity) = entity == word) != null) {
                entities.add({
                    entityType = "ghl_object";
                    value = word;
                    confidence = 0.9;
                });
            };
        };
        
        // Extract time references
        let timeWords = ["today", "tomorrow", "yesterday", "week", "month", "year"];
        for (word in words.vals()) {
            if (Array.find<Text>(timeWords, func(timeWord) = timeWord == word) != null) {
                entities.add({
                    entityType = "time_reference";
                    value = word;
                    confidence = 0.8;
                });
            };
        };
        
        // Extract numbers (simplified)
        for (word in words.vals()) {
            if (word == "1" or word == "2" or word == "5" or word == "10") {
                entities.add({
                    entityType = "number";
                    value = word;
                    confidence = 0.7;
                });
            };
        };
        
        Buffer.toArray(entities)
    };

    private func calculateConfidence(intent: Intent, entities: [Entity], words: [Text]): Float {
        var baseConfidence: Float = 0.3;
        
        // Boost confidence based on intent match
        switch (intent) {
            case (#Unknown) { baseConfidence := 0.1 };
            case (_) { baseConfidence := 0.6 };
        };
        
        // Boost confidence based on entity count
        let entityBoost = Float.fromInt(entities.size()) * 0.1;
        baseConfidence := baseConfidence + entityBoost;
        
        // Boost confidence based on keyword density
        let wordCount = Float.fromInt(words.size());
        if (wordCount > 0.0) {
            let ghlEntityCount = Float.fromInt(Array.fold<Entity, Int>(entities, 0, func(acc, entity) {
                if (entity.entityType == "ghl_object") acc + 1 else acc
            }));
            let density = ghlEntityCount / wordCount;
            baseConfidence := baseConfidence + (density * 0.2);
        };
        
        // Cap confidence at 1.0
        if (baseConfidence > 1.0) { 1.0 } else { baseConfidence }
    };

    private func shouldRequireApproval(intent: Intent, context: CommandContext): Bool {
        switch (intent) {
            case (#Delete(_)) { true };  // Always require approval for deletions
            case (#Create({ objectType })) {
                // Require approval for critical objects
                objectType == "workflow" or objectType == "campaign" or objectType == "automation"
            };
            case (#Automation(_)) { true };  // Require approval for automations
            case (_) { 
                // Require approval for high-priority operations
                context.priority >= 3 
            };
        }
    };

}