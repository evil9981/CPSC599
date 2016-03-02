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

class RequestEntity : NetMessage
{
    var msg_type: msgType
    
    var type: GameScene.BuildMode
    var location: int2
    var parent_id : Int

    init(type: GameScene.BuildMode, location: int2,  parent_id: Int)
    {
        self.msg_type = msgType.RequestEntity
        
        self.type = type
        self.location = location
        self.parent_id = parent_id
    }
    
    init(json: JSON)
    {
        self.msg_type = msgType(rawValue: json["msg_type"].stringValue)!
        self.type = GameScene.BuildMode(rawValue: json["type"].intValue)!
        let x = Int32(json["location"]["x"].floatValue)
        let y = Int32(json["location"]["y"].floatValue)
        self.location = int2(x, y)
        self.parent_id = json["parent_id"].intValue
    }
    
    func toJSON() -> String
    {
        let str: String =
        "{" +
            " \"msgType\" : \"\(self.msg_type.rawValue)\"," +
            " \"type\" : \(type.rawValue)," +
            " \"location\" : { \"x\":\(self.location.x), \"y\":\(self.location.y) }," +
            " \"parent_id\" : \(self.parent_id)" +
        "}"
        
        return str;
    }
}
