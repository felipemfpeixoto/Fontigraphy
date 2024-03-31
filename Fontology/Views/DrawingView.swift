import SwiftUI
import PencilKit
import UIKit

struct DrawingView: View {
    @State private var isDrawing = true
    @State private var color: Color = .black
    @State private var pencilType: PKInkingTool.InkType = .pencil
    @State private var colorPicker = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.undoManager) private var undoManager
    
    
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
            ZStack {
                DrawingCanvasView(canvas: $canvas, isDrawing: $isDrawing, pencilType: $pencilType, color: $color, lastDrawing: lastDrawing)
                    .navigationBarTitleDisplayMode(.inline)
                
                GridOverlay()
            }
            .navigationBarItems(leading: saveSVGButton)
            .edgesIgnoringSafeArea(.all)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    
                    Button {
                        undoManager?.undo()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    
                    Button {
                        undoManager?.redo()
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                    }
                    
                    Button {
                        isDrawing = false
                    } label: {
                        Image(systemName: "eraser.line.dashed")
                    }
                    
                    Divider()
                        .rotationEffect(.degrees(90))
                    
                    Menu {
                        
                        
                        Button {
                            // Menu: Pencil
                            isDrawing = true
                            pencilType = .pencil
                        } label: {
                            Label("Pencil", systemImage: "pencil")
                        }
                        
                        Button {
                            // Menu: pen
                            isDrawing = true
                            pencilType = .pen
                        } label: {
                            Label("Pen", systemImage: "pencil.tip")
                        }
                        
                        Button {
                            // Menu: Marker
                            isDrawing = true
                            pencilType = .marker
                        } label: {
                            Label("Marker", systemImage: "paintbrush.pointed")
                        }
                        
                        Button {
                            // Menu: Monoline
                            isDrawing = true
                            pencilType = .monoline
                        } label: {
                            Label("Monoline", systemImage: "pencil.line")
                        }
                        
                        Button {
                            // Menu: pen
                            isDrawing = true
                            pencilType = .fountainPen
                        } label: {
                            Label("Fountain", systemImage: "paintbrush.pointed.fill")
                        }
                        
                        Button {
                            // Menu: Watercolor
                            isDrawing = true
                            pencilType = .watercolor
                        } label: {
                            Label("Watercolor", systemImage: "eyedropper.halffull")
                        }
                        
                        Button {
                            // Menu: Crayon
                            isDrawing = true
                            pencilType = .crayon
                        } label: {
                            Label("Crayon", systemImage: "pencil.tip")
                        }
                    } label: {
                        Image(systemName: "hand.draw")
                    }
                    .sheet(isPresented: $colorPicker) {
                        ColorPicker("Pick color", selection: $color)
                            .padding()
                    }
                    Button {
                        
                        isDrawing = true
                        pencilType = .fountainPen
                    } label: {
                        Label("Fountain", systemImage: "scribble.variable")
                    }
                    Button {
                        // Marker
                        isDrawing = true
                        pencilType = .marker
                    } label: {
                        Label("Marker", systemImage: "paintbrush.pointed")
                    }
                    
                    Button {
                        // Water Color
                        isDrawing = true
                        pencilType = .watercolor
                    } label: {
                        Label("Watercolor", systemImage: "eyedropper.halffull")
                    }
                    
                    Divider()
                        .rotationEffect(.degrees(90))
                    
                    // Color picker
                    Button {
                        // Pick a color
                        colorPicker.toggle()
                    } label: {
                        Label("Color", systemImage: "paintpalette")
                    }
                    
                }
                
                // Collaboration tools
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        saveDrawing()
                    } label: {
                        VStack {
                            Image(systemName: "square.and.arrow.down.on.square")
                            Text("Save")
                                .font(.caption2)
                        }
                    }
                }
            }
            .tint(.black)
        }
    }
    
    func saveDrawing() {
        let drawingImage = canvas.drawing.image(from: canvas.drawing.bounds, scale: 2.0)
        
        guard let pngData = drawingImage.pngData() else {
            print("Failed to convert image to PNG data.")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(UIImage(data: pngData)!, nil, nil, nil)
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
        
        // Convertendo o JSON em dados
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("Failed to convert JSON to data")
            return
        }
        
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

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvas: PKCanvasView
    @Binding var isDrawing: Bool
    @Binding var pencilType: PKInkingTool.InkType
    @Binding var color: Color
    
    let lastDrawing: PKDrawing?
    
    var ink: PKInkingTool {
        PKInkingTool(pencilType, color: UIColor(color))
    }
    
    let eraser = PKEraserTool(.bitmap)
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        canvas.tool = isDrawing ? ink : eraser
        canvas.alwaysBounceVertical = true
        
        let toolPicker = PKToolPicker.init()
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        
        
        if lastDrawing != nil {
            canvas.drawing = lastDrawing!
        }
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = isDrawing ? ink : eraser
    }
}

struct GridOverlay: View {
    let lineWidth: CGFloat = 1
    let lineHeight: CGFloat = 1
    let dash: [CGFloat] = [6, 6] // Define o padrão de traço
    var body: some View {
        ZStack{
            VStack {
               
                //Primeira Pontilhada Horizontal
                Rectangle()
                    .frame(height: lineHeight)
                    .foregroundColor(.white)
                    .background(GeometryReader { proxy in
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 1))
                            path.addLine(to: CGPoint(x: proxy.size.width, y: 1))
                        }
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: dash))
                        //padrão de traço
                    })
                    .position(x: 590, y: 150)
                
                
                
                // Altura-X
                Rectangle()
                    .frame(height: lineHeight)
                    .foregroundColor(.black)
                    .background(GeometryReader { proxy in
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
                        }

                    })
                    .position(x: 590, y: 100)
                
                
              
                //Primeira Linha Vertical
                Rectangle()
                    .frame(width: lineWidth)
                    .foregroundColor(.white)
                    .background(GeometryReader { proxy in
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 1060))
                            path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
                        }
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: dash))
                        //padrão de traço
                    })
                    .position(x: 120, y: -350)
                
                
                
                
                //Linha Base
                Rectangle()
                    .frame(height: lineHeight)
                    .foregroundColor(.black)
                    .background(GeometryReader { proxy in
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
                        }

                    })
                    .position(x: 590, y: 200)
                
               
                
                // Segunda Linha Vertical
                Rectangle()
                    .frame(width: lineWidth)
                    .foregroundColor(.white)
                    .background(GeometryReader { proxy in
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 910))
                            path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
                        }
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: dash))
                        //padrão de traço
                    })
                    .position(x: 420, y: -390)

                
                
                // Terceira Linha Vertical
                Rectangle()
                    .frame(width: lineWidth)
                    .foregroundColor(.white)
                    .background(GeometryReader { proxy in
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 1060))
                            path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
                        }
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: dash))
                        //padrão de traço
                    })
                    .position(x: 740, y: -450)
                
              
                
                
                //Segunda Pontilhada Horizontal
                Rectangle()
                    .frame(height: lineHeight)
                    .foregroundColor(.white)
                    .background(GeometryReader { proxy in
                                        Path { path in
                                            path.move(to: CGPoint(x: 0, y: 1))
                                            path.addLine(to: CGPoint(x: proxy.size.width, y: 1))
                                        }
                                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: dash))
                                    })
                    .position(x: 590, y: -10)
                
                
                
                //Quarta Linha Vertical
                Rectangle()
                    .frame(width: lineWidth)
                    .foregroundColor(.white)
                    .background(GeometryReader { proxy in
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 1060))
                            path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
                        }
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: dash))
                        //padrão de traço
                    })
                    .position(x: 1070, y: -750)
            }
        }
    }
}

#Preview{
    DrawingView(character: "A", typographyName: "Mengo", lastDrawing: nil)
}
