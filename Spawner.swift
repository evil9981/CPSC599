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
    var unitCooldown : Float
    
    static var spawn_points : [int2] = [int2(42,40) , int2(42,37),
        int2(42,7)  , int2(42,4),
        int2(5,9)   , int2(5,6) ]
    
    var selected_spawn_point : int2
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, tower_texture: SKTexture, gridSize: int2, visSize: CGPoint, towerCost: Int, unitCooldown: Float, temp: Bool = false)
    {
        self.selected_spawn_point = Spawner.spawn_points[0]
        self.unitCooldown = unitCooldown
        
        super.init(scene: scene, grid_position: grid_position, world_position: world_position, tower_texture: tower_texture, gridSize: gridSize, visSize: visSize, buildingCost: towerCost, temp: temp)
        
    }
    
    override func update(delta: NSTimeInterval)
    {
        
    }
}
