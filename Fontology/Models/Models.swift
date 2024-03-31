import Foundation
import PencilKit
import CodableExtensions

struct Character: Codable {
    var character: String
    var svgString: String
    var drawing: PKDrawing?
    var pngDrawing: Data?
}

struct Typography: Codable {
    var name: String
    var characters: [Character]
    var isExported: Bool
    
    var uppercaseDrawing: Data?
    var lowercaseDrawing: Data?
    
    
    init(name: String, characters: [Character]) {
        self.name = name
        self.characters = characters
        self.isExported = false
    }
}

struct MyTypographies: Codable {
    var createdTypographies: [Typography]
}
