import Foundation
import SpriteKit

extension SKNode
{
    class func unarchiveFromFile(file: NSString) -> SKNode?
    {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks")
        {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)
            
        }
    }
}