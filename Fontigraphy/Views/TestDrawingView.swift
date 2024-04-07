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
            DrawingViewTest2(canvas: $canvas, lastDrawing: lastDrawing)
                .frame(width: 150, height: 150)
                .border(.black)
                .navigationTitle(character)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: saveSVGButton)
        }
    }
    
    var saveSVGButton: some View {
        ZStack {
            Button(action: {
                svgString = saveImage()
                let pngData = getPngData()
                typographyManager.editCharacterSVGString(typographyName: typographyName, character: character, newSVGString: svgString, newDrawing: drawing, pngDrawing: pngData)
//                callAPIWithSVG()
            }) {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.title)
            }
        }
    }
    
    func getPngData() -> Data? {
        let drawingImage = drawing?.image(from: canvas.drawing.bounds, scale: 1.0)
        guard let pngData = drawingImage!.pngData() else {
            print("Failed to convert image to PNG Data")
            return nil
        }
        return pngData
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
        guard let url = URL(string: "http://139.82.106.157:5000/convert") else {
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
        
        svgString += "<path d=\"\(pathToSVGPathData(path))\" style=\"fill:none;stroke:black;stroke-width:20\" />\n"
        
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

// Estudar como passar o desenho salvo feito anteriormente para traduzir
struct DrawingViewTest2: UIViewControllerRepresentable {
    
    @Binding var canvas: PKCanvasView
    
    let lastDrawing: PKDrawing?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        self.canvas.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(canvas)
        canvas.widthAnchor.constraint(equalTo: vc.view.widthAnchor).isActive = true
        canvas.heightAnchor.constraint(equalTo: vc.view.heightAnchor).isActive = true
        canvas.drawingPolicy = .anyInput
        if lastDrawing != nil {
            canvas.drawing = lastDrawing!
        }
        return vc
    }
    
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        ()
    }
}

#Preview {
    TestDrawingView(character: "A", typographyName: "Mengo", lastDrawing: nil)
}
