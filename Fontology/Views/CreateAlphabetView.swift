import SwiftUI

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
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(fontName)
                        .foregroundStyle(.black)
                        .font(.title.weight(.bold))
                    Spacer()
                    menuButton
                    exportButton
                }
                .padding(.leading)
                Spacer()
                ScrollView {
                    charactersGrid
                }
                Spacer()
            }
        }
//        .navigationTitle(fontName)
//        .navigationBarTitleDisplayMode(.large)
    }
    
    var menuButton: some View {
        Menu {
            Button("Aa") {
                selectedOption = "Aa"
                selectedAlphabet = .complete
            }
            Button("AA") {
                selectedOption = "AA"
                selectedAlphabet = .uppercase
            }
            Button("aa") {
                selectedOption = "aa"
                selectedAlphabet = .lowercase
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
            print("Ta funcionando ainda nao doidao")
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(Color.ourLightGray)
                Text("Exportar TTF")
                    .foregroundStyle(.black)
            }
            .frame(width: 127, height: 36)
            .padding(.trailing)
        })
    }
    
    var charactersGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(itemSize), spacing: spacing), count: Int(itemsPerRow)), spacing: spacing) {
            ForEach(alphabetAndNumbers, id: \.self) { element in
//                self.users = self.users.filter { $0.icloudID == dao.userID?.recordName }
                if let caractere = myFont.characters.filter({ $0.character == element }).first {
                    NavigationLink(destination: TestDrawingView(character: element, typographyName: fontName, lastDrawing: caractere.drawing)) {
                        ZStack {
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color.ourLightGray) // Cor do quadrado
                                    .font(.headline)
                                VStack {
                                    ZStack {
                                        Rectangle()
                                            .foregroundStyle(Color.ourGray)
                                            .frame(height: 32)
                                        Text(element)
                                            .foregroundStyle(.white)
                                            .font(.title3.weight(.semibold))
                                    }
                                    Spacer()
                                }
                            }
                            .frame(width: itemSize, height: itemSize)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Text(element)
                                .font(.system(size: itemSize - 70))
                                .foregroundStyle(Color.ourGray)
                                .padding(.top)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct CustomMenuStyle: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .foregroundColor(.black) // Definindo a cor do texto do botão
            .frame(width: 66, height: 36)
            .background(Color.ourLightGray) // Definindo a cor de fundo do botão
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}

struct DetailView: View {
    var item: String
    
    var body: some View {
        Text("Detalhes do item \(item)")
            .navigationTitle("Item \(item)")
    }
}

//#Preview {
//    CreateAlphabetView(fontName: "Arial", myFont: <#Typography#>)
//}
