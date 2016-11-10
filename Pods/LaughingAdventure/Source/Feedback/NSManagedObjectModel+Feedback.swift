/*
 * Copyright 2016 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import CoreData

internal extension NSManagedObjectModel {
    static func createFeedbackV1() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        
        //create entities
        // # Conversation #
        let conversationDesc = NSEntityDescription()
        conversationDesc.name = "Conversation"
        conversationDesc.managedObjectClassName = Conversation.entityName()
        
        let conversationLastMessageTime = NSAttributeDescription()
        conversationLastMessageTime.name = "lastMessageTime"
        conversationLastMessageTime.attributeType = .dateAttributeType
        
        let conversationSnippet = NSAttributeDescription()
        conversationSnippet.name = "snippet"
        conversationSnippet.attributeType = .stringAttributeType
        
        let conversationUnseen = NSAttributeDescription()
        conversationUnseen.name = "hasUpdate"
        conversationUnseen.attributeType = .booleanAttributeType
        conversationUnseen.defaultValue = false
        
        // # Message #
        let messageDesc = NSEntityDescription()
        messageDesc.name = "Message"
        messageDesc.managedObjectClassName = Message.entityName()
        
        let messageTime = NSAttributeDescription()
        messageTime.name = "postedAt"
        messageTime.attributeType = .dateAttributeType
        
        let messageBody = NSAttributeDescription()
        messageBody.name = "body"
        messageBody.attributeType = .stringAttributeType
        
        let messageSentBy = NSAttributeDescription()
        messageSentBy.name = "sentBy"
        messageSentBy.attributeType = .stringAttributeType
        messageSentBy.isOptional = true
        
        // # Setting #
        let settingDesc = NSEntityDescription()
        settingDesc.name = "Setting"
        settingDesc.managedObjectClassName = Setting.entityName()
        
        let settingKey = NSAttributeDescription()
        settingKey.name = "key"
        settingKey.attributeType = .integer32AttributeType
        
        let settingValue = NSAttributeDescription()
        settingValue.name = "value"
        settingValue.attributeType = .stringAttributeType
        settingValue.isOptional = true
        
        //# common properties
        let recordName = NSAttributeDescription()
        recordName.name = "recordName"
        recordName.attributeType = .stringAttributeType

        let commonRecordData = NSAttributeDescription()
        commonRecordData.name = "recordData"
        commonRecordData.attributeType = .binaryDataAttributeType
        commonRecordData.allowsExternalBinaryDataStorage = true
        
        let syncNeeded = NSAttributeDescription()
        syncNeeded.name = "syncNeeded"
        syncNeeded.attributeType = .booleanAttributeType
        syncNeeded.defaultValue = false
        
        let syncFailed = NSAttributeDescription()
        syncFailed.name = "syncFailed"
        syncFailed.attributeType = .booleanAttributeType
        syncFailed.defaultValue = false
        
        //relationships
        let conversationHasManyMessages = NSRelationshipDescription()
        conversationHasManyMessages.destinationEntity = messageDesc
        conversationHasManyMessages.name = "messages"
        conversationHasManyMessages.deleteRule = .cascadeDeleteRule
        
        let messageBelongsToOneConversation = NSRelationshipDescription()
        messageBelongsToOneConversation.destinationEntity = conversationDesc
        messageBelongsToOneConversation.name = "conversation"
        messageBelongsToOneConversation.deleteRule = .nullifyDeleteRule
        messageBelongsToOneConversation.minCount = 1
        messageBelongsToOneConversation.maxCount = 1
        
        conversationHasManyMessages.inverseRelationship = messageBelongsToOneConversation
        messageBelongsToOneConversation.inverseRelationship = conversationHasManyMessages

        conversationDesc.properties = [conversationLastMessageTime, recordName, conversationHasManyMessages, conversationSnippet, commonRecordData, syncNeeded, syncFailed, conversationUnseen]
        messageDesc.properties = [messageTime, messageBody, messageBelongsToOneConversation, commonRecordData, recordName, syncNeeded, syncFailed, messageSentBy]
        settingDesc.properties = [settingKey, settingValue]
        
        let entities = [conversationDesc, messageDesc, settingDesc]
        
        model.entities = entities
        
        return model
    }
}
