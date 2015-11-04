//
//  GameEntity.swift
//  GameApp
//
//  Created by User on 2015-11-03.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameEntity : GKEntity
{
    var entity_id: Int = -1
    
    override init()
    {
        
        // Inc static entity id and set current
        entity_id = GameEntity.get_next_id()
        
        super.init()
    }
    
    // MARK: Static methods and properties
    static var next_entity_id : Int = -1
    static func get_next_id() -> Int
    {
        GameEntity.next_entity_id++;
        return GameEntity.next_entity_id;
    }
    
}
