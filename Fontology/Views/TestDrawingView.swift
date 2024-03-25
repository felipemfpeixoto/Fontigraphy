import SwiftUI
import Foundation
import CoreGraphics
import UIKit
import PencilKit

struct TestDrawingView: View {
    @EnvironmentObject var typographyManager: TypographyManager
    
    @State private var canvas = PKCanvasView()
    @State var drawing: PKDrawing?
    @State var path: CGPath?
    
    @State var svgString: String = ""
    let character: String
    let typographyName: String
    let lastDrawing: PKDrawing?
    
    var body: some View {
        NavigationStack {
            DrawingViewTest(canvas: $canvas, lastDrawing: lastDrawing)
                .navigationTitle(character)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: saveSVGButton)
        }
    }
    
    var saveSVGButton: some View {
        ZStack {
            Button(action: {
                svgString = saveImage()
                typographyManager.editCharacterSVGString(typographyName: typographyName, character: character, newSVGString: svgString, newDrawing: drawing)
//                callAPIWithSVG()
            }) {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.title)
            }
        }
    }
    
    func saveImage() -> String {
        drawing = canvas.drawing
        path = getPathFromDrawing(drawing: drawing!)
        let svg = pathsToSVG(path!)
        print(svg)
        // Cria o objeto com o texto em SVG
        let svgObjetct = Character(character: character, svgString: svg)
        // Faz o request da API
        // sendRequest(svgObject: svgObjetct)
        return svg
    }
    
    // Função para enviar a solicitação da API
    func sendRequest(svgObject: Character) {
        // Criando o JSON a partir do objeto SVGObject
        let json: [String: Any] = [
            "character": String(svgObject.character),
            "svgContent": svgObject.svgString
        ]
        print("Ai vem o json:")
        print(json)
        
        // Convertendo o JSON em dados
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("Failed to convert JSON to data")
            return
        }
        print("Ai vem o json convertido:")
        
        // Definindo a URL da API
        guard let url = URL(string: "http://127.0.0.1:5000/convert") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Fazendo a solicitação
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            
            if let data = data {
                // Salvando o arquivo .ttf localmente
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent("fontfile.ttf")
                
                do {
                    try data.write(to: fileURL)
                    print("Font file saved at: \(fileURL)")
                } catch {
                    print("Error saving font file: \(error.localizedDescription)")
                }
            } else {
                print("No data received")
            }
        }.resume()
    }

    // Função que traduz o path do desenho e traduz para SVG
    func pathsToSVG(_ path: CGPath) -> String {
        svgString = "<svg width=\"300\" height=\"300\" xmlns=\"http://www.w3.org/2000/svg\">\n"
        
        svgString += "<path d=\"\(pathToSVGPathData(path))\" style=\"fill:none;stroke:black;stroke-width:2\" />\n"
        
        svgString += "</svg>"
        
        return svgString
    }

    func pathToSVGPathData(_ path: CGPath) -> String {
        var pathString = ""
        var points = [CGPoint](repeating: .zero, count: 3)
        var currentPoint = CGPoint.zero
        path.applyWithBlock { elementPointer in
            let element = elementPointer.pointee
            switch element.type {
            case .moveToPoint:
                currentPoint = element.points[0]
                pathString += "M \(currentPoint.x) \(currentPoint.y) "
            case .addLineToPoint:
                currentPoint = element.points[0]
                pathString += "L \(currentPoint.x) \(currentPoint.y) "
            case .addQuadCurveToPoint:
                points[0] = currentPoint
                points[1] = element.points[0]
                points[2] = element.points[1]
                pathString += "Q \(points[1].x) \(points[1].y) \(points[2].x) \(points[2].y) "
                currentPoint = element.points[1]
            case .addCurveToPoint:
                points[0] = currentPoint
                points[1] = element.points[0]
                points[2] = element.points[1]
                pathString += "C \(points[1].x) \(points[1].y) \(points[2].x) \(points[2].y) \(element.points[2].x) \(element.points[2].y) "
                currentPoint = element.points[2]
            case .closeSubpath:
                pathString += "Z"
            @unknown default:
                break
            }
        }
        return pathString
    }
    
    // Função para pegar o CGPath de um PKDrawing
    func getPathFromDrawing(drawing: PKDrawing) -> CGMutablePath {
        let path = CGMutablePath()
        for stroke in drawing.strokes {
            let points = stroke.path
            if let firstPoint = points.first {
                path.move(to: firstPoint.location)
                for point in points.dropFirst() {
                    path.addLine(to: point.location)
                }
            }
        }
        
        return path
    }
    
    func callAPIWithSVG() {
        print("callAPIWithSVG")
        // Assuming you have an API request function, replace the URL and parameters accordingly
        let apiURL = URL(string: "https://example.com/api")!
        let svgData = svgString
        print(svgData)
        
//        var request = URLRequest(url: apiURL)
//        request.httpMethod = "POST"
//        request.setValue("application/svg+xml", forHTTPHeaderField: "Content-Type")
//        request.httpBody = svgData
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            // Step 2: Receive response from API
//            if let data = data {
//                // Step 3: Save received .ttf file to device's file system
//                saveTTFFromData(data)
//            }
//        }.resume()
    }
    
    func saveTTFFromData(_ data: Data) {
            // Save the received .ttf file to the device's file system
            // For example, you can save it in the Documents directory
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("example.ttf")
                do {
                    try data.write(to: fileURL)
                    print("TTF file saved successfully.")
                } catch {
                    print("Error saving TTF file: \(error)")
                }
            }
        }
}

// Estudar como passar o desenho salvo feito anteriormente para traduzir
struct DrawingViewTest: UIViewRepresentable {
    
    @Binding var canvas: PKCanvasView
    
    let lastDrawing: PKDrawing?
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        if lastDrawing != nil {
            canvas.drawing = lastDrawing!
        }
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        print("Mengo")
    }
}

#Preview {
    TestDrawingView(character: "A", typographyName: "Mengo", lastDrawing: nil)
}
