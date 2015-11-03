//
//  BasicTurret.swift
//  GameApp
//
//  Created by User on 2015-11-03.
//  Copyright © 2015 Eric. All rights reserved.
//

import SpriteKit
import GameplayKit

class BasicTurret : GKEntity
{
    var scene: GameScene
    
    var visualComp: VisualComponent!
    var logicComp: LogicComponent!
    
    
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, tower_texture : SKTexture)
    {
        self.scene = scene
        
        super.init()
        
        // Set visual component and add it to the scene
        self.visualComp = VisualComponent(scene: scene, texture: tower_texture, world_position: world_position)
        self.addComponent(visualComp)
        
        // Add the logical component that moves creatures on the tiles set
        self.logicComp = LogicComponent(tiles: scene.tiles, unit: self, pos: grid_position)
        self.addComponent(logicComp)
    }

}
