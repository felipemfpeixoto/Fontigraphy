import SwiftUI
import PencilKit
import UIKit

struct DrawingView: View {
    @State private var isDrawing = true
    @State private var color: Color = .black
    @State private var pencilType: PKInkingTool.InkType = .monoline
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
    var masterDrawing: Data?
    @State var masterName: String?
    
    @State var isShowingCommands: Bool = false
    
    @State var showingAlert = false
    @Binding var isShowingMask: Bool
    @State var isShowingPopovers = false // ta icompleto
    @Binding var isSHowingMaster: Bool
    
    var body: some View {
        ZStack {
            if isShowingMask {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(character)
                                .font(.system(size: geometry.size.width * 0.325))
                                .foregroundStyle(.black.opacity(0.15))
                                .padding(.bottom, geometry.size.height / 28)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
//            DrawingCanvasView(canvas: $canvas, isDrawing: $isDrawing, pencilType: $pencilType, color: $color, lastDrawing: lastDrawing)
//                .navigationBarTitleDisplayMode(.inline)
            
            DrawingViewTest3(canvas: $canvas, isDrawing: $isDrawing, pencilType: $pencilType, color: $color, lastDrawing: lastDrawing)
                .navigationBarTitleDisplayMode(.inline)
                .frame(width: 700, height: 700)
            
            GridOverlay()
            
            commandsButton
            
            if masterDrawing != nil && masterName != character {
                masterBox
            }
        }
        .overlay {
            if isShowingPopovers {
                ZStack {
                    Color.black.opacity(0.5)
                        .onTapGesture {
                            withAnimation(Animation.spring(duration: 0.5)) {
                                isShowingPopovers = false
                            }
                        }
                        .ignoresSafeArea()
                    ascendersPopup
                    descendersPopup
                    xHeightPopup
                }
            }
        }
        .onDisappear {
            svgString = saveImage()
            if svgString == "" {
                typographyManager.editCharacterSVGString(typographyName: typographyName, character: character, newSVGString: "", newDrawing: nil, pngDrawing: nil)
            } else {
                let pngData = getPngData()
                typographyManager.editCharacterSVGString(typographyName: typographyName, character: character, newSVGString: svgString, newDrawing: drawing, pngDrawing: pngData)
                if masterName == character {
                    typographyManager.editMasterCharacter(typographyName: typographyName, pngDrawing: pngData, characterName: character)
                    print("Entrou")
                }
            }
        }
        .alert("Are you sure you want to set this character as Master?", isPresented: $showingAlert, actions: {
            Button(role: .cancel) {
                // tornar o caractere em questao o master
            } label: {
                Text("Cancel")
            }
            Button(role: .none) {
                // tornar o caractere em questao o master
                if masterName != character {
                    masterName = character
                } else {
                    masterName = nil
                }
            } label: {
                Text("Set")
            }
        })
        .navigationBarItems(trailing:
                                VStack {
                                    Spacer()
                                    HStack {
                                        Menu {
                                            Button(role: .none) {
                                                showingAlert = true
                                            } label: {
                                                Label("Save as master", systemImage: "star")
                                            }
                                        } label: {
                                            Image(systemName: "star.circle.fill")
                                                .font(.system(.largeTitle))
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(masterName == character ? .black : .gray, masterName == character ? .yellow : .ourLightGray)
                                        }
                                        Toggle(isOn: $isShowingMask) {
                                                
                                            }
                                            .toggleStyle(MyToggleStyle())
                                        Button {
                                            withAnimation(Animation.spring(duration: 0.5)) {
                                                isShowingPopovers.toggle()
                                            }
                                        } label: {
                                            Image(systemName: "questionmark.circle.fill")
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(.black, .yellow)
                                                .font(.system(.largeTitle))
                                        }

                                    }
                                })
        .tint(.black)
        .navigationBarBackButtonHidden(isShowingPopovers) // Oculta apenas o botão de volta
    }
    
    var commandsButton: some View {
        HStack(alignment: .top) {
            ZStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 150)
                        .frame(width: 108, height: isShowingCommands ? 466 : 108)
                        .foregroundStyle(Color.amareloClarinho)
                    VStack {
                        VStack(spacing: isShowingCommands ? 50 : 0) {
                            Button {
                                // Menu: Monoline
                                isDrawing = true
                                pencilType = .monoline
                            } label: {
                                Image(systemName: "pencil.tip")
                                    .font(.system(size: 45))
                                    .opacity(isShowingCommands ? 1 : 0)
                            }
                            Button {
                                isDrawing = false
                            } label: {
                                Image(systemName: "eraser.line.dashed")
                                    .font(.system(size: 45))
                                    .opacity(isShowingCommands ? 1 : 0)
                            }
                            HStack {
                                
                                Button {
                                    undoManager?.undo()
                                } label: {
                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                        .font(.system(size: 40))
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.black, Color.amareloClarinhoMaisEscuro)
                                        .opacity(isShowingCommands ? 1 : 0)
                                }
                                Button {
                                    undoManager?.redo()
                                } label: {
                                    Image(systemName: "arrow.uturn.forward.circle.fill")
                                        .font(.system(size: 40))
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.black, Color.amareloClarinhoMaisEscuro)
                                        .opacity(isShowingCommands ? 1 : 0)
                                }
                            }
                        }
//                            Spacer()
                    }
                    .padding(.top, isShowingCommands ? 112.5 : 0)
                }
                Button {
                    withAnimation(Animation.easeInOut(duration: 0.4)) {
                        isShowingCommands.toggle()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .frame(width: 108)
                            .foregroundStyle(Color.amareloClarinhoMaisEscuro) // Mudar para o amarelo claro do design
                            .shadow(color: .black.opacity(0.3), radius: 4, y: 6)
                        if isDrawing {
                            Image(systemName: "pencil.tip")
                                .font(.system(size: 50))
                        } else {
                            Image(systemName: "eraser.line.dashed")
                                .font(.system(size: 50))
                        }
                    }
                }
                .padding(.bottom, isShowingCommands ? 358 : 0)
                
            }
            .padding(.leading, 30)
            Spacer()
        }
        .frame(height: 450) // Mudar para de acordo com o GeometryReader
    }
    
    var masterBox: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation(Animation.spring(duration: 0.5)) {
                        isSHowingMaster.toggle()
                    }
                } label: {
                    if isSHowingMaster {
                        ZStack {
                            Rectangle()
                                .foregroundStyle(Color.white) // Cor do quadrado
                                .font(.headline)
                                .frame(width: 150, height: isSHowingMaster ? 150 : 32)
                            Image(uiImage: UIImage(data: masterDrawing!)!)
                                .resizable()
                                .frame(width: 70, height: 70)
                                .scaledToFit()
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(Color.yellow)
                                        .frame(height: 32)
                                    Text("Master")
                                        .foregroundStyle(.black)
                                        .font(.title3.weight(.semibold))
                                }
                                Spacer()
                            }
                        }
                        .frame(width: 150, height: isSHowingMaster ? 150 : 32)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                        .padding(50)
                    } else {
                        VStack {
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color.yellow)
                                    .frame(height: 32)
                                Text("Master")
                                    .foregroundStyle(.black)
                                    .font(.title3.weight(.semibold))
                            }
                        }
                        .frame(width: 150, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                        .padding(50)
                    }
                }
                .shadow(color: .black.opacity(0.4), radius: 7.5, y: isSHowingMaster ? 0 : 10)
            }
        }
//        .background {
//            Color.blue
//        }
    }
    
    var ascendersPopup: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(spacing: 0) {
                    Triangle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 13)
                                .frame(width: 234, height: 203)
                                .foregroundStyle(Color.ourReallyLightGray)
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.white)
                                        .frame(width: 234, height: 41)
                                    Text("Ascenders")
                                }
                                Spacer()
                                ScrollView {
                                    Text("Ascender in typography refers to the part of a letter that extends above the X line of a type or font. Letters with very short or missing ascenders can be difficult to read.")
                                        .font(.system(.callout))
                                        .padding()
                                }
                                Spacer()
                            }
                            .frame(width: 234, height: 203)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .frame(width: 234, height: 203)
                }
                .frame(width: 234, height: 230)
                .padding(.leading, 250)
                Spacer()
            }
            .padding(.top, UIScreen.main.bounds.height / 3.6)
            Spacer()
        }
    }
    
    var descendersPopup: some View {
        VStack {
            Spacer()
            HStack {
                HStack(spacing: 0) {
                    VStack {
                        if UIScreen.main.bounds.height > 1360 || UIScreen.main.bounds.width > 1360 {
                            Triangle2()
                                .fill(Color.ourReallyLightGray)
                                .frame(width: 30, height: 30)
                                .padding(.bottom, UIScreen.main.bounds.height / 10)
                        } else {
                            Triangle2()
                                .fill(Color.ourReallyLightGray)
                                .frame(width: 30, height: 30)
                        }
                    }
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 13)
                                .frame(width: 234, height: 203)
                                .foregroundStyle(Color.ourReallyLightGray)
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.white)
                                        .frame(width: 234, height: 41)
                                    Text("Descenders")
                                }
                                Spacer()
                                ScrollView {
                                    Text("Descenders are the parts that extend below the base line. Letters with very long or short descenders can create a visual imbalance in the text.")
                                        .font(.system(.callout))
                                        .padding()
                                }
                                Spacer()
                            }
                            .frame(width: 234, height: 203)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .frame(width: 234, height: 203)
                }
                .frame(width: 234, height: 230)
                .padding(.leading, 250)
                Spacer()
            }
            .padding(.bottom, UIScreen.main.bounds.height / 15)
            .padding(.leading, 175)
        }
    }
    
    var xHeightPopup: some View {
        VStack {
            HStack(alignment: .bottom) {
                Spacer()
                VStack(spacing: 0) {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 13)
                                .frame(width: 234, height: 203)
                                .foregroundStyle(Color.ourReallyLightGray)
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.white)
                                        .frame(width: 234, height: 41)
                                    Text("X-Height")
                                }
                                Spacer()
                                ScrollView {
                                    Text("The x-height is the term applied to the distance between the baseline and the midline. Observing the x-height is important for solving typographic legibility problems.")
                                        .font(.system(.callout))
                                        .padding()
                                }
                                Spacer()
                            }
                            .frame(width: 234, height: 203)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .frame(width: 234, height: 203)
                    Triangle3()
                        .fill(Color.ourReallyLightGray)
                        .frame(width: 30, height: 30)
                }
                .frame(width: 234, height: 230)
                .padding(.trailing, 90)
            }
//            .padding(.top, UIScreen.main.bounds.height / 10)
//            Spacer()
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
                dismiss()
            }) {
                Image(systemName: "arrowshape.turn.up.backward")
                    .font(.title)
                    .foregroundStyle(.black)
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
        let pathConverted = pathToSVGPathData(path)
        if pathConverted == "" {
            return ""
        }
        
        svgString = "<svg width=\"300\" height=\"300\" xmlns=\"http://www.w3.org/2000/svg\">\n"
        
        svgString += "<path d=\"\(pathConverted)\" style=\"fill:none;stroke:black;stroke-width:20\" />\n"
        
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
        PKInkingTool(pencilType, color: UIColor(color), width: 7.5)
    }
    
    let eraser = PKEraserTool(.bitmap)
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        canvas.tool = isDrawing ? ink : eraser
        print(canvas.tool)
        canvas.alwaysBounceVertical = true
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        
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

struct DrawingViewTest3: UIViewControllerRepresentable {
    
    @Binding var canvas: PKCanvasView
    @Binding var isDrawing: Bool
    @Binding var pencilType: PKInkingTool.InkType
    @Binding var color: Color
    
    let lastDrawing: PKDrawing?
    
    var ink: PKInkingTool {
        PKInkingTool(pencilType, color: UIColor(color), width: 7.5)
    }
    
    let eraser = PKEraserTool(.bitmap)
    
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
        
        canvas.drawingPolicy = .anyInput
        canvas.tool = isDrawing ? ink : eraser
        print(canvas.tool)
        canvas.alwaysBounceVertical = true
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        
        let toolPicker = PKToolPicker.init()
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        
        return vc
    }
    
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        canvas.tool = isDrawing ? ink : eraser
    }
}


struct GridOverlay: View {
    var body: some View {
        
        ZStack{
            VStack (spacing: 90 ){
                Spacer()
                LineHorizon()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                    .frame(height: 0.5)
                    .foregroundStyle(.gray)
                    
                
                
                LineHorizon()
                    .stroke(style: StrokeStyle(lineWidth: 0.5))
                    .frame(height: 1)
                    .foregroundStyle(.gray)

                
                
                Spacer()
                LineHorizon()
                    .stroke(style: StrokeStyle(lineWidth: 0.5))
                    .frame(height: 1)
                    .foregroundStyle(.gray)
                    .padding(.top, 50)

                
                
                
                
                LineHorizon()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                    .frame(height: 0.5)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 20)
                

                
                Spacer()
            }

            HStack {
                VStack{
                    Spacer()
                    Text("Ascenders")
                        .foregroundStyle(.gray)
                        .bold()
                        .padding(.bottom, 130)
                    //                    .padding(.leading, 200)
                    
                    Spacer()
                    
                    Text("Descenders")
                        .bold()
                        .foregroundStyle(.gray)
                        .padding(.top, 50)
                    //                    .padding(.leading, 200)
                    
                    Spacer()
                }
                .padding(.leading, 300)
                .padding(.top, 40)
                Spacer()
            }
            
            
            
            HStack{
                Spacer()
                Text("X-height")
                    .bold()
                    .padding(.trailing, 185)
                    .padding(.top, 290)
                    .foregroundStyle(.gray)
                
            }
            Spacer()
            VStack {
                HStack{
                    Spacer()
                    LineVert()
                        .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [6]))
                        .frame(height: 1)
                        .foregroundStyle(.gray)
                        .padding(.leading, UIScreen.main.bounds.width / 4.5)
                    
                    Spacer()
                    
                    LineVert()
                        .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [6]))
                        .frame(height: 1)
                        .foregroundStyle(.gray)
                        .padding(.trailing, UIScreen.main.bounds.width / 4.5)
                    Spacer()
                }
                HStack {
                    Spacer()
                    LineVert2()
                        .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [6]))
                        .frame(height: 1)
                        .foregroundStyle(.gray)
                        .padding(.leading, UIScreen.main.bounds.width / 4.5)
                    Spacer()
                    
                    LineVert2()
                        .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [6]))
                        .frame(height: 1)
                        .foregroundStyle(.gray)
                        .padding(.trailing, UIScreen.main.bounds.width / 4.5)
                    Spacer()
                }
            }
        }
        Spacer()
    }
}

struct LineHorizon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct LineVert: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 1020))
        
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        return path
    }
}

struct LineVert2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: -1020))
        
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Iniciando o ponto na parte superior central do retângulo
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        
        // Desenhando uma linha para a parte inferior esquerda do retângulo
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Desenhando uma linha para a parte inferior direita do retângulo
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Fechando o caminho, voltando para o topo central
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

struct Triangle2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Iniciando o ponto na parte esquerda central do retângulo
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        
        // Desenhando uma linha para a parte superior direita do retângulo
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        // Desenhando uma linha para a parte inferior direita do retângulo
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Fechando o caminho, voltando para a esquerda central
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        
        return path
    }
}

struct Triangle3: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Iniciando o ponto na parte superior esquerda do retângulo
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        
        // Desenhando uma linha para a parte inferior do retângulo
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        // Desenhando uma linha para o ponto inferior direito do retângulo
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        
        // Fechando o caminho, voltando para o topo esquerdo
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        
        return path
    }
}


//#Preview{
//    DrawingView(character: "A", typographyName: "Mengo", lastDrawing: nil, masterDrawing: nil, masterName: "a", isShowingMask: false, isShowingPopovers: <#T##Bool#>)
//}
