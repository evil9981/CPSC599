//
//  Spawner.swift
//  GameApp
//
//  Created by Roger Sun on 2015-12-01.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class Spawner: Building
{
    var mazeTiles : [Tile] = [Tile]()
    
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, tower_texture: SKTexture, gridSize: int2, visSize: CGPoint, towerCost: Int, temp: Bool = false)
    {
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: tower_texture, gridSize: gridSize, visSize: visSize, buildingCost: towerCost, temp: temp)
        
    }
    
    override func update(delta: NSTimeInterval){}
}
