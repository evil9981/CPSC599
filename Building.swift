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
    var buildingCost: Int
    
    // Size is x/y of how many tiles it takes in x and how many tiles it takes in y
    init(scene: GameScene, grid_position: int2, world_position: CGPoint, tower_texture : SKTexture, gridSize : int2, visSize: CGPoint, buildingCost: Int, temp : Bool = false)
    {
        self.scene = scene
        self.buildingCost = buildingCost
        
        super.init()
        
        // Set visual component and add it to the scene
        self.visualComp = VisualComponent(scene: scene, parent_entity: self, texture: tower_texture, world_position: world_position, size: visSize)
        self.addComponent(visualComp)
        
        if (!temp)
        {
            // Add the logical component that moves creatures on the tiles set
            self.gridComp = GridComponent(tiles: scene.tiles, unit: self, pos: grid_position, size: gridSize)
            self.addComponent(gridComp)
        }
    }
    
    func buildInProgress()
    {
        let world_position: CGPoint = visualComp.node.position
        
        visualComp.scene.removeChildrenInArray([visualComp.node])
        
        if (self is RegularTower)
        {
            let size = CGSize(width: 1.2 * Tile.tileWidth,height: 1.2 * Tile.tileHeight)
            let animation = Animation(scene: scene, textures: RegularTower.baseT_Building, speed: 3, visSize: size , worldPos: world_position, death_anim: false)
            animation.run()
        }
        
        else if (self is FireTower)
        {
            let size = CGSize(width: 1.2 * Tile.tileWidth,height: 1.2 * Tile.tileHeight)
            let animation = Animation(scene: scene, textures: FireTower.fireT_Building, speed: 3, visSize: size , worldPos: world_position, death_anim: false)
            animation.run()
        }
        
        else if(self is IceTower)
        {
            let size = CGSize(width: 1.2 * Tile.tileWidth,height: 1.2 * Tile.tileHeight)
            let animation = Animation(scene: scene, textures: IceTower.iceT_Building, speed: 3, visSize: size , worldPos: world_position, death_anim: false)
            animation.run()
        }
        
        else if(self is OrcBuilding)
        {
            let size = CGSize(width: 1.2 * Tile.tileWidth,height: 1.2 * Tile.tileHeight)
            let animation = Animation(scene: scene, textures: OrcBuilding.orcB_Building, speed: 3, visSize: size , worldPos: world_position, death_anim: false)
            animation.run()
        }
        
        else if(self is GoblinBuilding)
        {
            let size = CGSize(width: 1.2 * Tile.tileWidth,height: 1.2 * Tile.tileHeight)
            let animation = Animation(scene: scene, textures: GoblinBuilding.goblinB_Building, speed: 3, visSize: size , worldPos: world_position, death_anim: false)
            animation.run()
        }

        else if(self is TrollBuilding)
        {
            let size = CGSize(width: 1.2 * Tile.tileWidth,height: 1.2 * Tile.tileHeight)
            let animation = Animation(scene: scene, textures: TrollBuilding.trollB_Building, speed: 3, visSize: size , worldPos: world_position, death_anim: false)
            animation.run()
        }

        else if(self is DefenderPowerSource)
        {
            let size = CGSize(width: 1.2 * Tile.tileWidth,height: 1.2 * Tile.tileHeight)
            let animation = Animation(scene: scene, textures: DefenderPowerSource.dps_Building, speed: 3, visSize: size , worldPos: world_position, death_anim: false)
            animation.run()
        }
        
        else if(self is AttackerPowerSource)
        {
            let size = CGSize(width: 1.2 * Tile.tileWidth,height: 1.2 * Tile.tileHeight)
            let animation = Animation(scene: scene, textures: AttackerPowerSource.aps_Building, speed: 3, visSize: size , worldPos: world_position, death_anim: false)
            animation.run()
        }
        
    }
    
    func update(delta: NSTimeInterval)
    {
        
    }
    
    func destroy()
    {
        scene.removeChildrenInArray([self.visualComp.node])
        scene.all_units.removeValueForKey(self.entity_id)
    }
}

