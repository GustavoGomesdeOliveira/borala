//
//  Message.swift
//  FinalChallenge
//
//  Created by C. Williamberg on 24/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import Foundation

class Message{
    var id: String?
    let senderId: String
    let senderName: String
    let text: String
    var timeStamp: Float?
    
    init(id: String, senderId: String, senderName: String, text: String, timeStamp: Float) {
        self.id = id
        self.senderId = senderId
        self.senderName = senderName
        self.text = text
        self.timeStamp = timeStamp
    }
    
    init(senderId: String, senderName: String, text: String) {
        self.senderId = senderId
        self.senderName = senderName
        self.text = text
    }
    
    func toDictionary() -> [String: Any]{
        return ["id": self.id, "senderId": self.senderId, "senderName": self.senderName,
                "text": self.text, "timeStamp": self.timeStamp]
    }
}
