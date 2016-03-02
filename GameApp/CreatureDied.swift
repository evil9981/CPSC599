//
//  LogInMsg.swift
//  GameApp
//
//  Created by User on 2016-02-03.
//  Copyright © 2016 Eric. All rights reserved.
//

import Foundation
import SpriteKit
import SwiftyJSON

class CreatureDied : NetMessage
{
    var msg_type: msgType
    
    var entityID: Int
    var type: GameScene.BuildMode
    var location: int2
    var time : String
    
    init(entityID: Int, type: GameScene.BuildMode, location: int2,  time: String)
    {
        self.msg_type = msgType.CreatureDied
        
        self.type = type
        self.entityID = entityID
        self.location = location
        self.time = time
    }

    func toJSON() -> String
    {
        let str: String =
        "{" +
            " \"msgType\" : \"\(self.msg_type.rawValue)\"," +
            " \"type\" : \(type.rawValue)," +
            " \"entityID\" : \(self.entityID)," +
            " \"location\" : { \"x\":\(self.location.x), \"y\":\(self.location.y) }," +
            " \"time\" : \(self.time)" +
        "}"
        
        return str;
    }
}
