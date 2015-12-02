//
//  Tile.swift
//  GameApp
//
//  Created by User on 2015-11-01.
//  Copyright © 2015 Eric. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

public class Tile
{
    var position : int2
    var type : TileType
    var moveOpt: TileOpts
    
    var towersInRange : Dictionary<Int, Tower> = Dictionary<Int, Tower>()
    
    init(position: int2)
    {
        self.position = position
        self.type = TileType.NoneUsable
        self.moveOpt = TileOpts.None
    }
    
    func add_tower( tower: Tower)
    {
        towersInRange[tower.entity_id] = tower
    }
    
    func notify_towers(unit: Unit)
    {
        for tower in towersInRange.values
        {
            tower.towerComp.add_unit_to_range(unit)
        }
    }
    
    var building_on_tile : Building?
    func place_building( building: Building)
    {
        building_on_tile = building
    }
    
    static let tileWidth: CGFloat = 64
    static let tileHeight: CGFloat = 64

    static var attacker_set : Set<Int> = [406] //[ 10, 120, 121, 122, 136, 138, 152, 153, 154, 169, 170, 185 ]
    static var defender_set : Set<Int> = [121,122,123,141,142,143,161,162,163] //[ 11, 12, 13, 27, 28, 29, 43, 44, 45, 78, 79, 94, 95, 111, 112, 127, 128]
    static var road_set : Set<Int> = [22,23] //[ 14, 15, 30, 31, 46, 47, 59, 60, 61, 62, 63, 75, 76, 77, 91, 92, 93 ]
    static var goal_set : Set<Int> = [310] //[148, 149, 150, 164, 165, 166, 180, 181, 182]
    
    static func init_tile_sets()
    {
        // Road tiles
        let first_tile = 181
        let last_tile = 223
        for num in (first_tile ... last_tile)
        {
            self.road_set.insert(num)
        }
    }
    
    static public func makeTileFromType(type: Int, pos: int2) -> Tile
    {
        if (attacker_set.contains(type))
        {
            return AttackerTile(position: pos)
        }
        else if (defender_set.contains(type))
        {
            return DefenderTile(position: pos)
        }
        else if (road_set.contains(type))
        {
            return MazeTile(position: pos)
        }
        else if (goal_set.contains(type))
        {
            return GoalTile(position: pos)
        }
        
        return NonUsableTile(position: pos)
    }
    
    static let left_arrow = 707
    static let up_arrow = 708
    static let right_arrow = 709
    static let down_arrow = 710
    
    static public func parseTileOpts(type: Int) -> TileOpts
    {
        switch (type)
        {
        case left_arrow:
            return TileOpts.MoveLeft
            
        case up_arrow:
            return TileOpts.MoveUp
            
        case right_arrow:
            return TileOpts.MoveRight
            
        case down_arrow:
            return TileOpts.MoveDown
            
        default:
            return TileOpts.None
        }
    }
    
    static public func getTile(tiles : [[Tile]], pos: int2) -> Tile
    {
        let row = tiles.count - 1 - Int(pos.y)
        let column = Int(pos.x)
        
        return tiles[row][column]
    }
}