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
    case NewBuilding = "NewBuilding"
    case NewCreature = "NewCreature"
    case CreatureDied = "CreatureDied"
    case LifeReduced = "LifeReduced"
    case EndGame = "EndGame"
}

protocol NetMessage
{
    func toJSON() -> String
}