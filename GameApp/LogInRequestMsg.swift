

//
//  LogInMsg.swift
//  GameApp
//
//  Created by User on 2016-02-03.
//  Copyright © 2016 Eric. All rights reserved.
//

import Foundation
import SwiftyJSON

class LogInRequestMsg : NetMessage
{
    var msg_type: msgType
    
    var role: GameRole
    var username: String
    var uniqueId: String
    
    init(role: GameRole, username: String, uniqueId: String)
    {
        self.msg_type = msgType.LogInRequest
        
        self.role = role
        self.username = username
        self.uniqueId = uniqueId
    }
    
    func toJSON() -> String
    {
        let json = JSON(["msgType":self.msg_type.rawValue, "role":role.rawValue, "username":self.username,"uniqueId":self.uniqueId])
        return json.rawString()!
    }
}
