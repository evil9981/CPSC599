//
//  LogInMsg.swift
//  GameApp
//
//  Created by User on 2016-02-03.
//  Copyright © 2016 Eric. All rights reserved.
//

import Foundation
import SwiftyJSON
import SpriteKit
import PureJsonSerializer

class NewBuilding : NetMessage
{
    var msg_type: msgType
    var type : GameScene.BuildMode
    var entity_id: Int
    var location: int2
    var time_to_spawn: String
    
    init(json: JSON)
    {
        self.msg_type = msgType(rawValue: json["msg_type"].stringValue)!
        self.type = GameScene.BuildMode(rawValue: json["type"].intValue)!
        self.entity_id = json["entity_id"].intValue
        let x = json["location"]["x"].intValue
        let y = json["location"]["y"].intValue
        self.location = int2(Int32(x),Int32(y))
        self.time_to_spawn = json["msg_type"].stringValue
    }
    
    init(type: GameScene.BuildMode, entity_id: Int, location: int2, time_to_spawn: String)
    {
        self.msg_type = msgType.NewBuilding
        self.type = type
        self.entity_id = entity_id
        self.location = location
        self.time_to_spawn = time_to_spawn
    }
    
    func toJSON() -> String
    {
        let str: String =
        "{" +
            " \"msgType\" : \(self.msg_type.rawValue)," +
            " \"type\" : \(type.rawValue)," +
            " \"entityID\" : \(self.entity_id)," +
            " \"location\" : { \"x\":\(self.location.x), \"y\":\(self.location.y) }," +
            " \"time\" : \(self.time_to_spawn)" +
        "}"
        
        return str
    }
}
