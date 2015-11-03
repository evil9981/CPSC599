//
//  LogicComponent.swift
//  GameApp
//
//  Created by User on 2015-11-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import GameplayKit
import SpriteKit

class LogicComponent: GKComponent
{
    var tiles : [[Tile]]
    var unit: GKEntity
    
    var current_pos : int2
    var current_tile : Tile!
    
    init( tiles : [[Tile]], unit: GKEntity, pos: int2)
    {
        self.tiles = tiles
        self.unit = unit
        self.current_pos = pos
        self.current_tile = Tile.getTile(tiles, pos: current_pos)
        
        super.init()
    }
    
}
