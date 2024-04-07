import SwiftUI
import CodableExtensions

enum SelectedAlphabet {
    case complete
    case uppercase
    case lowercase
}

struct CreateAlphabetView: View {
    
    @State var selectedAlphabet: SelectedAlphabet = .complete
    
    let letrasMaiusculasEMinusculas: [String] = [
        "A", "a", "B", "b", "C", "c", "D", "d", "E", "e",
        "F", "f", "G", "g", "H", "h", "I", "i", "J", "j",
        "K", "k", "L", "l", "M", "m", "N", "n", "O", "o",
        "P", "p", "Q", "q", "R", "r", "S", "s", "T", "t",
        "U", "u", "V", "v", "W", "w", "X", "x", "Y", "y",
        "Z", "z",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
    ]
    
    let myFont: Typography

    let letrasMaiusculas: [String] = [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
        "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
        "U", "V", "W", "X", "Y", "Z",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
    ]

    let letrasMinusculas: [String] = [
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
        "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
        "u", "v", "w", "x", "y", "z",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
    ]

    var alphabetAndNumbers: [String] {
        switch selectedAlphabet {
        case .complete:
            return letrasMaiusculasEMinusculas
        case .uppercase:
            return letrasMaiusculas
        case .lowercase:
            return letrasMinusculas
        }
    }
    
    let itemsPerRow = 5
    let spacing: CGFloat = 30 // Espaçamento entre os quadrados
    let itemSize: CGFloat = UIScreen.main.bounds.width / 6 // Tamanho dos quadrados

    let fontName: String
    
    @State var selectedOption: String? = nil
    
    @State var isLoadingTTF: Bool = false
    
    @State var isPresenting: Bool = false
    
    @State var isShowingMask = false
    @State var isSHowingMaster = false
    
    var documentsDirectory: URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    
    var fileName: String {
        "\(fontName).ttf"
    }
    
    @State var fileExists: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(fontName)
                        .foregroundStyle(.black)
                        .font(.system(size: 48).weight(.bold))
                    Spacer()
                    menuButton
                    exportButton
                }
                .padding(.horizontal, 48)
                .background(.white)
                Spacer()
                ScrollView {
                    charactersGrid
                }
                Spacer()
            }
        }
        .task {
            let filePath = documentsDirectory.appendingPathComponent(fileName).path
            let exists = FileManager.default.fileExists(atPath: filePath)
            if exists {
                fileExists = true
            }
        }
        .background{
            ZStack {
//                Color.white
//                    .ignoresSafeArea()
                Image("backgroundAlphabet")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                    .padding(.top, UIScreen.main.bounds.height)
            }
        }
        .fullScreenCover(isPresented: $isPresenting, content: {
//            ExportingSheet(isPresenting: $isPresenting, isLoading: $isLoadingTTF, fileName: fileName)
            ExportView(isPresenting: $isPresenting, isLoading: $isLoadingTTF, typography: myFont, fileName: fileName)
        })
        
    }
    
    var menuButton: some View {
        Menu {
            Button {
                selectedOption = "Aa"
                selectedAlphabet = .complete
            } label: {
                Label("Complete", systemImage: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
            }
            Button {
                selectedOption = "AA"
                selectedAlphabet = .uppercase
            } label: {
                Label("Uppercase", systemImage: "arrowshape.up")
            }
            Button {
                selectedOption = "aa"
                selectedAlphabet = .lowercase
            } label: {
                Label("Lowercase", systemImage: "arrowshape.down")
            }
        } label: {
            Text(selectedOption != nil ? selectedOption! : "Aa")
                .font(.title3.weight(.bold))
            Image(systemName: "chevron.up.chevron.down")
        }
        .padding()
        .menuStyle(CustomMenuStyle()) // Aplicando um estilo personalizado ao menu
    }
    
    var exportButton: some View {
        Button(action: {
            isPresenting = true
            isLoadingTTF = true
            callAPIWithTypography()
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 100)
                    .foregroundStyle(Color.yellow)
                Text("Export TTF")
                    .foregroundStyle(.black)
            }
            .frame(width: 127, height: 36)
            .padding(.trailing)
        })
    }
    
    var charactersGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(itemSize), spacing: spacing), count: Int(itemsPerRow)), spacing: spacing) {
            ForEach(alphabetAndNumbers, id: \.self) { element in
                if let caractere = myFont.characters.filter({ $0.character == element }).first {
//                    NavigationLink(destination: TestDrawingView(character: element, typographyName: fontName, lastDrawing: caractere.drawing)) {
                    NavigationLink(destination: DrawingView(character: element, typographyName: fontName, lastDrawing: caractere.drawing, masterDrawing: myFont.master != nil ? myFont.master! : nil, masterName: myFont.master != nil ? myFont.masterName! : nil, isShowingMask: $isShowingMask, isSHowingMaster: $isSHowingMaster)) {
                        ZStack {
                            ZStack {
                                if caractere.pngDrawing != nil {
                                    Rectangle()
                                        .foregroundStyle(Color.white) // Cor do quadrado
                                        .font(.headline)
                                    Image(uiImage: UIImage(data: caractere.pngDrawing!)!)
                                        .resizable()
                                        .frame(width: itemSize/2, height: itemSize/2)
                                    VStack {
                                        ZStack {
                                            Rectangle()
                                                .foregroundStyle(Color.yellow)
                                                .frame(height: 32)
                                            Text(element)
                                                .foregroundStyle(.black)
                                                .font(.title3.weight(.semibold))
                                        }
                                        Spacer()
                                    }
                                } else {
                                    Rectangle()
                                        .foregroundStyle(Color.ourLightGray)
                                        .font(.headline)
                                    VStack {
                                        ZStack {
                                            Rectangle()
                                                .foregroundStyle(Color.yellow)
                                                .frame(height: 32)
                                            Text(element)
                                                .foregroundStyle(.black)
                                                .font(.title3.weight(.semibold))
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            .frame(width: itemSize, height: itemSize)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: .black.opacity(0.3), radius: 7.5, y: 2)
                            
                            if caractere.pngDrawing == nil {
                                Text(element)
                                    .font(.system(size: itemSize - 70))
                                    .foregroundStyle(Color.ourGray)
                                    .padding(.top)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    // Função para fazer a solicitação da API com a tipografia serializada como JSON
    func callAPIWithTypography() {
        print("callAPIWithTypography")
        // http://139.82.106.157:5000
        // Call para o lab
//        guard let url = URL(string: "http://10.46.40.6:5001/convert") else {
//            print("Invalid URL")
//            return
//        }
        
        // Call para a máquina virtual
        guard let url = URL(string: "http://139.82.106.157:5000/convert") else {
            print("Invalid URL")
            return
        }
        
        // Call para testes em casa -> http://127.0.0.1:5001
//        guard let url = URL(string: "http://127.0.0.1:5001/convert") else {
//            print("Invalid URL")
//            return
//        }
        
        guard let data = myFont.asDictionary?.asData else {
            fatalError("Si fudeu")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Step 2: Receive response from API
            if let data = data {
                // Step 3: Handle the response data
                // Handle the received data as per your requirement
                saveTTFFromData(data)
                isLoadingTTF = false
            }
        }.resume()
    }
    
    func saveTTFFromData(_ data: Data) {
        // Save the received .ttf file to the device's file system
        // For example, you can save it in the Documents directory
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("\(myFont.name).ttf")
            do {
                try data.write(to: fileURL)
                print("TTF file saved successfully.")
                fileExists = true
                isLoadingTTF = false
                print(fileURL)
            } catch {
                print("Error saving TTF file: \(error)")
            }
        }
    }
}

struct CustomMenuStyle: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .foregroundColor(.black) // Definindo a cor do texto do botão
            .frame(width: 66, height: 36)
            .background(Color.yellow) // Definindo a cor de fundo do botão
            .clipShape(RoundedRectangle(cornerRadius: 100))
    }
}

struct ExportingSheet: View {
    
    @Binding var isPresenting: Bool
    
    @Binding var isLoading: Bool
    
    var documentsDirectory: URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    
    let fileName: String
    
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            VStack {
                if isLoading {
                    ProgressView()
                        .controlSize(.extraLarge)
                } else {
                    HStack {
                        Button(action: {
                            isPresenting = false
                        }, label: {
                            Image(systemName: "x.circle")
                                .foregroundStyle(.white)
                                .font(.system(size: 50))
                        })
                        .padding(30)
                        Spacer()
                    }
                    Spacer()
                    ShareLink(item: documentsDirectory.appendingPathComponent(fileName)) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 100)
                                .frame(width: 140, height: 70)
                                .foregroundStyle(.yellow)
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(Color.black)
                                .font(.system(size: 50))
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    CreateAlphabetView(myFont: Typography(name: "Mengo", characters: []), fontName: "Arial")
}
