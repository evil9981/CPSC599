import Foundation
import Starscream

class NetworkSingleton: WebSocketDelegate
{
    static let instance = NetworkSingleton()
    var ws: WebSocket!
    var scene: NetworkableScene!
    
    private init()
    {
        ws = WebSocket(url: NSURL(string: "ws://192.168.0.14:8005")!)
        ws.connect()
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
        debugPrint("Message recieved: " + text)
    }
    
    func writeToNet(msg: NetMessage)
    {
        ws.writeString(msg.toJSON())
    }
}