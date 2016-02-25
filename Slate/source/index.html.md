---
title: API Reference

language_tabs:
  - json

toc_footers:
  - <a href='#'>Back to the full site</a>
  - <a href='https://github.com/tripit/slate'>Documentation Powered by Slate</a>

includes:

search: true
---

# Introduction

Welcome to the Swincide API documentation. As mentioned, there are three types of messages:

1. Start/End match messages: these messages are meant to setup and close matches, they are exchanged between each client and the server. 
2. Messages to be relayed to matched Clients: these messages are meant for the oposite matched Client, the server only needs to relay and log them.
3. Messages to update the Server of the game status: these messages are meant for the server to keep a state of the match and help analyze game data in later stages.

# Start/End match messages
## LogInRequest

> An example of a valid LogInRequest:

```json
{
    "msgType":"LogInRequest", 
    "role":"attacker", 
    "username":"SomeString",
    "uniqueId":"AnotherString"
}
```

This message is the first message that is sent from the Client to the Server.

Field | Value 
-------------- | -------------- 
msgType | [Valid msgType](#msgtype) 
role | [Valid role](#role) 
username | String, Game Center name
uniqueId | String, Game Center Unique ID

## LogIn

> An example of a valid LogIn:

```json
{
    "msgType":"LogInRequest", 
    "role":"attacker"
}
```

This message is the first message that is sent from the Server to the Client and is a response message to a [LogInRequestMsg](#loginrequestmsg).

Field | Value 
-------------- | -------------- 
msgType | [Valid msgType](#msgtype) 
role | [Valid role](#role) 

## EndGame

> An example of a valid EndGame:

```json
{
    "msgType":"EndGame", 
    "winner":"attacker"
}
```

This message is sent from the Server to the clients when an end game state is reached on the server. 

An end game state happens with one of the two following conditions:

1. A [LifeReduced](#lifereduced) message arrives with a field "LivesLeft" set to 0, this means that the attacker has won.
2. The match timer has reached the maximum time. 

Field | Value 
-------------- | -------------- 
msgType | [Valid msgType](#msgtype) 
winner | [Valid role](#role)

# Relayed Messages
## RequestEntity
> An example of a valid RequestEntity:

```json
{
    "msgType": "RequestEntity",
    "type": 1,
    "location": 
    {
        "x": 1,
        "y": 55 
    },
    "parent_id":1
}
```

This message is sent from a client to the server to request a building to be placed. The sending client then plays a "building in progress" animation. The server starts a timer for the given building and allocates a unique entity ID for that building and creatures for this match. 

The first allocated entity ID should be 2 - the defender's initial powersource will be automatically assigned the value 0 to it's entity ID and the attacker's first powersrouce will be given an entity ID of 1.

Upon reciecving the message, the server also relays it to the oposite side - this way the other client will know to build the temp entity.
Finally, when the server's timer for the given request ends, a [NewEntity](#newentity) message is sent to both sides to "activate" an actual entity instead of the temp ones. 

Field | Value 
-------------- | -------------- 
msgType | [Valid msgType](#msgtype) 
type | [Valid Type](#type)
location | Has an x and y property that indicates location on the game's logic grid. For buildings, this is where we build the building. For creatures, this is the location at which they will spawn.
parent_id | This is only relevant to creatures. Buildings have this set to -1. This represents which building is spawning this creature and is used to display the "busy" animation on that building.

## NewEntity

> An example of a valid NewEntity:

```json
{
    "msgType": "NewEntity",
    "type": 1,
    "entityID": 35,
    "location": 
    {
        "x": 1,
        "y": 55 
    },
    "parent_id":1
}
```

This message is sent from a client to the server to be relayed to the matched client. It indicates one of the clients has preformed an action that resulted in a new building.

Field | Value 
-------------- | -------------- 
msgType | [Valid msgType](#msgtype) 
type | [Valid Type](#type)
entityID | A Unique integer a client has for a given entity. Two clients might give different Entity ID's to the same creature.
location | Has an x and y property that indicates location on the game's logic grid.
parent_id | This is only relevant to creatures. Buildings have this set to -1. This represents which building is spawning this creature and is used to stop the "busy" animation on that building.

<aside class="notice">
This message is identical between buildings and creatures. The distinguishing element is the type field.
</aside>

# Update Server Game State
## CreatureDied

> An example of a valid CreatureDied:

```json
{
    "msgType": "CreatureDied",
    "type": 1,
    "entityID": 35,
    "location": 
    {
        "x": 1,
        "y": 55 
    },
    "time": "5:55"
}
```

This message is sent from both Clients to the server to indicate a unit has died. In the future, we can use this knowledge to keep gold values for players and make sure purchases of units and buildings are legal. 

Field | Value 
-------------- | -------------- 
msgType | [Valid msgType](#msgtype) 
type | [Valid Type](#type)
entityID | A Unique integer a client has for a given entity. Two clients might give different Entity ID's to the same creature.
location | Has an x and y property that indicates location on the game's logic grid.
time | String, indicates at what time in the game timer did this unit die.

<aside class="notice">
This messages are sent from both clients to the server and it is up to the server to make sure the state is only updated once. In the future, we might also double check that each message is indeed delivered twice, to observer bugs and complications.
</aside>

## LifeReduced

> An example of a valid LifeReduced:

```json
{
    "msgType": "LifeReduced",
    "livesLeft":1,
    "time": "5:55"
}
```

This message is sent from both Clients to the server to indicate an attacker unit has reached the pigs. If the livesLeft value is 0, the server should follow up with ending the game with a [EndGame](#endgame) message, where the attack is decalred the winner.

Field | Value 
-------------- | -------------- 
msgType | [Valid msgType](#msgtype) 
livesLeft | Integer, indicating how many lives are left for the defender.
time | String, indicates at what time in the game timer did this unit die.

<aside class="notice">
This messages are sent from both clients to the server and it is up to the server to make sure the state is only updated once. In the future, we might also double check that each message is indeed delivered twice, to observer bugs and complications.
</aside>

# Acceptable Types
## MsgType

Each message has to have at least on field in it, indicating which msgType the message stands for. The table below describes which msgTypes are valid. 

MsgType | Fields | Sender | Intended for
-------------- | -------------- | -------------- | -------------- 
LogInRequest | Side, Username, UserID | Client | Server
LogIn | Side | Server | Client
EndGame | Winner | Server | Both clients
RequestEntity | Type, EntityId, Location, Parent_ID | Client | Matched Client, relayed by Server
NewEntity | Type, EntityId, Location, Parent_ID | Client | Matched Client, relayed by Server
CreatureDied | Type, EntityId, Location, Time | Client | Server, will be sent by both Clients
LifeReduced | LivesLeft, Time | Client | Server, will be sent by both Clients

<aside class="warning">
Non-valid msgTypes are simpley ignored.
</aside>

## Role

Roles indicate possible choices for the client as to which side the player wishes to play. They are also used once the server decided which role to play for players that chose to "fill" any role.

Role | Value 
-------------- | -------------- 
Attacker | "attacker"
Defender | "defender"
Fill | "fill"

<aside class="warning">
Non-valid roles are simpley ignored and the connection to the requesting client is closed.
</aside>

## Type

Types are integers that represent a specific entity type in the game, such as creatures or buildings. It is used when an entity is created or destroyed. 

Type | Meaning 
-------------- | -------------- 
0 | Orc
1 | Goblin
2 | Troll
3 | None (Used internally by Client)
4 | RegularTower
5 | FireTower
6 | IceTower
7 | DefenderPowerSource
8 | OrcBuliding
9 | GoblinBuilding
10 | TrollBuilding
11 | AttackerPowerSource

<aside class="warning">
Non-valid types are simpley ignored.
</aside>

