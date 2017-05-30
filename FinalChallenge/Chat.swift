//
//  Chat.swift
//  FinalChallenge
//
//  Created by C. Williamberg on 24/05/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import Foundation

class Chat{
    var id: String!
    var lastMessage: Message!
    var pic: Data?
    
    init(id: String, pic: Data?, lastMessage: Message) {
        self.id = id
        self.pic = pic
        self.lastMessage = lastMessage
    }
    
}
