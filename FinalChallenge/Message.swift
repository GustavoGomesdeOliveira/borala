//
//  Message.swift
//  FinalChallenge
//
//  Created by C. Williamberg on 24/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import Foundation

class Message{
    var id: String
    var senderName: String
    var text: String
    var timeStamp: Float
    
    init(id: String, senderName: String, text: String, timeStamp: Float) {
        self.id = id
        self.senderName = senderName
        self.text = text
        self.timeStamp = timeStamp
    }
}
