import Foundation
import PencilKit

struct Character: Codable {
    var character: String
    var svgString: String
    var drawing: PKDrawing?
}

struct Typography: Codable {
    var name: String
    var characters: [Character]
    var isExported: Bool
    
    init(name: String, characters: [Character]) {
        self.name = name
        self.characters = characters
        self.isExported = false
    }
}

struct MyTypographies: Codable {
    var createdTypographies: [Typography]
}
