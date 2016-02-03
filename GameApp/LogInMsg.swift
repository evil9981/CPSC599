//
//  LogInMsg.swift
//  GameApp
//
//  Created by User on 2016-02-03.
//  Copyright © 2016 Eric. All rights reserved.
//

import Foundation

enum GameRole : String
{
    case attacker = "attacker"
    case defender = "defender"
}

class LogInMsg : NetMessage
{
    var type: msgType
    
    var role: GameRole
    var username: String
    var uniqueId: String
    
    init(role: GameRole, username: String, uniqueId: String)
    {
        self.type = msgType.LogIn
        
        self.role = role
        self.username = username
        self.uniqueId = uniqueId
    }
    
    func toJSON() -> String
    {
        
    }
}
