//
//  NetMessage.swift
//  GameApp
//
//  Created by User on 2016-02-03.
//  Copyright © 2016 Eric. All rights reserved.
//

import Foundation

enum msgType: String
{
    case LogInRequest = "LogInRequest"
    case LogIn = "LogIn"
    case BuildTower = "BuildTower"
    case SpawnCreature = "SpawnCreature"
}

protocol NetMessage
{
    var type: msgType { get set }
    
    func toJSON() -> String
}