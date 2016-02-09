//
//  LogInMsg.swift
//  GameApp
//
//  Created by User on 2016-02-03.
//  Copyright © 2016 Eric. All rights reserved.
//

import Foundation
import SwiftyJSON

class LogInMsg : NetMessage
{
    var type: msgType
    
    var role: GameRole
    
    init(role: String)
    {
        self.type = msgType.LogIn
        self.role = GameRole(rawValue: role)!
    }
    
    func toJSON() -> String
    {
        let json = JSON(["role":role.rawValue])
        return json.rawString()!
    }
}
