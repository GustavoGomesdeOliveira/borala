//
//  ChatConversation.swift
//  FinalChallenge
//
//  Created by Gustavo Gomes de Oliveira on 24/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import Foundation

class ChatConversation {
    
    var message: [String]!
    var pic: Data!
    var userName: String!
    
    init(message: [String], pic: Data, userName: String) {
        
        self.message = message
        self.pic = pic
        self.userName = userName
    }
    
    init(message: [String]) {
        
        self.message = message

    }
}
