//
//  BasicTurret.swift
//  GameApp
//
//  Created by User on 2015-11-03.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class Building: GameEntity
{
    var scene: GameScene
    
    var visualComp: VisualComponent!
    var gridComp: GridComponent!
    
    // Size is x/y of how many tiles it takes in x and how many tiles it takes in y
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, tower_texture : SKTexture, gridSize : int2, visSize: CGPoint)
    {
        self.scene = scene
        
        super.init()
        
        // Set visual component and add it to the scene
        self.visualComp = VisualComponent(scene: scene, parent_entity: self, texture: tower_texture, world_position: world_position, size: visSize)
        self.addComponent(visualComp)
        
        // Add the logical component that moves creatures on the tiles set
        self.gridComp = GridComponent(tiles: scene.tiles, unit: self, pos: grid_position, size: gridSize)
        self.addComponent(gridComp)

    }
    
    func update()
    {
        
    }

}