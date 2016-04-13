import Foundation
import Starscream

class NetworkSingleton: WebSocketDelegate
{
    static let instance = NetworkSingleton()
    var ws: WebSocket!
    var scene: NetworkableScene!
    var role : GameRole!
    var mode: GameMode!
    
    private init()
    {
        ws = WebSocket(url: NSURL(string: "ws://10.13.152.144:8005")!)
        ws.delegate = self
        ws.connect()
    }
    
    
    func update_role(role : GameRole)
    {
        self.role = role
    }
    
    func update_mode(mode: GameMode)
    {
        self.mode = mode
    }
    
    static func getInst(scene: NetworkableScene) -> NetworkSingleton
    {
        NetworkSingleton.instance.scene = scene
        
        return NetworkSingleton.instance
    }
    
    func websocketDidConnect(socket: WebSocket)
    {
        debugPrint("Connected to server!")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?)
    {
        debugPrint("Disconnected from server!")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData)
    {
        debugPrint("Recieved data that wasn't a string!")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String)
    {
        self.scene.updateFromNetwork(text)
    }
    
    func writeToNet(msg: NetMessage)
    {
        ws.writeString(msg.toJSON())
    }
}