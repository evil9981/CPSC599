//
//  LogInMsg.swift
//  GameApp
//
//  Created by User on 2016-02-03.
//  Copyright © 2016 Eric. All rights reserved.
//

import Foundation
import SwiftyJSON

class LifeReduced : NetMessage
{
    var msg_type: msgType
    
    var lifeLeft : Int
    var time: String
    

    init(livesLeft: Int, time: String)
    {
        self.msg_type = msgType.LifeReduced
        
        self.lifeLeft = livesLeft
        self.time = time
    }
    
    func toJSON() -> String
    {
        let str: String =
        "{" +
            " \"msgType\" : \"\(self.msg_type.rawValue)\"," +
            " \"lifeLeft\" : \(self.lifeLeft)," +
            " \"time\" : \(self.time)" +
        "}"
        
        return str
    }
}
