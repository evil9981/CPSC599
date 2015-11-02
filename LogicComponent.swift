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
    var unit: Unit
    var current_pos : int2
    var current_tile : Tile!
    
    init( tiles : [[Tile]], unit: Unit, pos: int2)
    {
        self.tiles = tiles
        self.unit = unit
        self.current_pos = pos
        self.current_tile = Tile.getTile(tiles, pos: current_pos)
        
        super.init()
        
        self.handle_move_opt()
    }
    
    func update()
    {
        switch(unit.movementComp.current_mov_option!)
        {
        case .MoveLeft:
            move_left()
            break
        case .MoveRight:
            move_right()
            break
        case .MoveUp:
            move_up()
            break
        case .MoveDown:
            move_down()
            break
        case .Treasure:
            debugPrint("REACHED THE TREASURE, OH NOES!")
            break
        case .None:
            break
        }
        
        if (!(current_tile is MazeTile))
        {
            unit.destroy()
        }
    }
    
    func handle_move_opt()
    {
        switch (self.current_tile.moveOpt)
        {
        case .MoveLeft:
            self.unit.movementComp.current_movement = unit.movementComp.moveLeft
            self.unit.movementComp.current_mov_option = TileOpts.MoveLeft
            break
        case .MoveRight:
            self.unit.movementComp.current_movement = unit.movementComp.moveRight
            self.unit.movementComp.current_mov_option = TileOpts.MoveRight
            break
        case .MoveUp:
            self.unit.movementComp.current_movement = unit.movementComp.moveUp
            self.unit.movementComp.current_mov_option = TileOpts.MoveUp
            break
        case .MoveDown:
            self.unit.movementComp.current_movement = unit.movementComp.moveDown
            self.unit.movementComp.current_mov_option = TileOpts.MoveDown
            break
        case .Treasure:
            debugPrint("REACHED THE TREASURE, OH NOES!")
            break
        case .None:
            break
        }
    }
    
    func move_left()
    {
        current_pos = int2(current_pos.x-1, current_pos.y)
        current_tile = Tile.getTile(tiles, pos: current_pos)

        handle_move_opt()
    }
    
    func move_right()
    {
        current_pos = int2(current_pos.x+1, current_pos.y)
        current_tile = Tile.getTile(tiles, pos: current_pos)

        handle_move_opt()
    }
    
    func move_up()
    {
        current_pos = int2(current_pos.x, current_pos.y+1)
        current_tile = Tile.getTile(tiles, pos: current_pos)
        
        handle_move_opt()
    }
    
    func move_down()
    {
        current_pos = int2(current_pos.x, current_pos.y-1)
        current_tile = Tile.getTile(tiles, pos: current_pos)
        
        handle_move_opt()
    }
}
