//
//  LogicComponent.swift
//  GameApp
//
//  Created by User on 2015-11-02.
//  Copyright © 2015 Eric. All rights reserved.
//

import GameplayKit
import SpriteKit

class GridComponent: GKComponent
{
    var tiles : [[Tile]]
    var unit: GameEntity
    
    var current_pos : int2
    var current_tile : Tile!
    var size: int2
    
    init( tiles : [[Tile]], unit: GameEntity, pos: int2, size: int2)
    {
        self.tiles = tiles
        self.unit = unit
        self.current_pos = pos
        self.current_tile = Tile.getTile(tiles, pos: current_pos)
        self.size = size
        
        super.init()
    }
    
    func move_unit_to_tile(new_pos : int2)
    {
        current_pos = new_pos
        current_tile = Tile.getTile(tiles, pos: current_pos)
        
        if unit is Unit
        {
            current_tile.notify_towers(unit as! Unit)
        }
    }
    
    func getTile(point: int2) -> Tile
    {
        return tiles[Int(point.x)][Int(point.y)]
    }
    
    func updateTilesWithTower(range: int2)
    {
        if (unit is Tower)
        {
            let tower = unit as! Tower
            
            let row_index : Int = Int(range.x)
            let column_index: Int = Int(range.y)
            
            let start_column_index = max(0, current_pos.x - column_index + size.x - 2 )
            let end_column_index = min( Int32(tiles[0].count - 1), current_pos.x + column_index + size.x )
            
            let start_row_index = max (0, current_pos.y - row_index)
            let end_row_index = min( Int32(tiles.count - 1), current_pos.y + row_index + size.y - 1)
            
            
            for row in start_row_index ... end_row_index
            {
                for column in start_column_index ... end_column_index
                {
                    let pos = int2(Int32(column), Int32(row))
                    let tile = Tile.getTile(tiles, pos: pos)
                    debugPrint(tile.position)
                    
                    tile.add_tower(tower)
                    tower.mazeTiles.append(tile)
                    
                }
            }
        }
    }
}
