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
    
    init(position: int2)
    {
        self.position = position
        self.type = TileType.NoneUsable
        self.moveOpt = TileOpts.None
    }
    
    static let tileWidth: CGFloat = 72
    static let tileHeight: CGFloat = 72

    static var attacker_set : Set<Int> = [ 10, 120, 121, 122, 136, 138, 152, 153, 154, 169, 170, 185 ]
    static var defender_set : Set<Int> = [ 11, 12, 13, 27, 28, 29, 43, 44, 45, 78, 79, 94, 95]
    static var road_set : Set<Int> = [ 14, 15, 30, 31, 46, 47, 59, 60, 61, 62, 63, 75, 76, 77, 91, 92, 93 ]
    static var treasure_set : Set<Int> = [148, 149, 150, 164, 165, 166, 180, 181, 182]
    
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
        else if (treasure_set.contains(type))
        {
            return TreasureTile(position: pos)
        }
        
        return NonUsableTile(position: pos)
    }
}