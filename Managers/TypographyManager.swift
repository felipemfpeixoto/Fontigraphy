import Foundation
import PencilKit

class TypographyManager: ObservableObject {
    @Published var myTypographies = MyTypographies(createdTypographies: [])
    
    init() {
        loadTypographies()
    }
    
    func loadTypographies() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentDirectory.appendingPathComponent("typographies.json")
        print(fileURL)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let typographies = try JSONDecoder().decode(MyTypographies.self, from: data)
                self.myTypographies = typographies
                print("Entrou")
                print(self.myTypographies)
            } catch {
                print("Error loading typographies: \(error.localizedDescription)")
            }
        } else {
            // Create a new blank JSON file in the documents directory
            let blankTypographies = MyTypographies(createdTypographies: [])
            do {
                let data = try JSONEncoder().encode(blankTypographies)
                try data.write(to: fileURL)
                self.myTypographies = blankTypographies
                print("Entrou2")
                print(self.myTypographies)
            } catch {
                print("Error creating and saving blank typographies: \(error.localizedDescription)")
            }
        }
    }
    
    func saveTypographies() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentDirectory.appendingPathComponent("typographies.json")
        
        do {
            let data = try JSONEncoder().encode(myTypographies)
            try data.write(to: fileURL)
            print(data)
        } catch {
            print("Error saving typographies: \(error.localizedDescription)")
        }
    }
    
    func addTypography(name: String) {
        let alphabetCharacters = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789"

        var characters: [Character] = []

        // Adicionando caracteres do alfabeto
        for char in alphabetCharacters {
            characters.append(Character(character: String(char), svgString: "", drawing: nil))
        }

        print(characters)
        
        let newTypography = Typography(name: name, characters: characters)
        myTypographies.createdTypographies.append(newTypography)
        saveTypographies()
    }
    
    func editCharacterSVGString(typographyName: String, character: String, newSVGString: String, newDrawing: PKDrawing?) {
        guard let typographyIndex = myTypographies.createdTypographies.firstIndex(where: { $0.name == typographyName }),
              let characterIndex = myTypographies.createdTypographies[typographyIndex].characters.firstIndex(where: { $0.character == character }) else {
            print("Typography or character not found")
            return
        }
        
        myTypographies.createdTypographies[typographyIndex].characters[characterIndex].svgString = newSVGString
        myTypographies.createdTypographies[typographyIndex].characters[characterIndex].drawing = newDrawing
        saveTypographies()
    }
}
