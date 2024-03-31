import SwiftUI

struct ContentView: View {
    @EnvironmentObject var typographyManager: TypographyManager
    
    @State var isPresentingAddTypography: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                    Image("mainBackground")
                }
                .ignoresSafeArea()
                VStack {
                    Spacer()
                    mainHeader
                    ScrollView(.horizontal) {
                        HStack(spacing: 20) {
                            Button {
                                // Botao para criar uma nova tipografia
                                isPresentingAddTypography.toggle()
                            } label: {
                                VStack {
                                    Spacer()
                                    newTypographyButton
                                }
                            }
                            .frame(width: 387, height: 387)
                            .padding(.leading, 100)
                            forEachTypographies
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $isPresentingAddTypography, content: {
            AddTypographyView(isSheetPresented: $isPresentingAddTypography)
        })
    }
    
    var mainHeader: some View {
        HStack {
            Text("Your Typographies")
                .font(.system(size: 48).weight(.bold))
                .padding(.leading, 120)
            Spacer()
            Button {
                // abre tutorial
            } label: {
                Image(systemName: "questionmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.black, .yellow)
                    .font(.system(size: 48))
                    .padding(.trailing, 120)
            }
        }
    }
    
    var newTypographyButton: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.ourLightGray)
                .frame(width: 387, height: 387)
                .shadow(color: .black.opacity(0.3), radius: 5, y: 5)
            VStack(alignment: .center) {
                Image(systemName: "plus")
                    .foregroundStyle(.black)
                    .font(.system(size: 128))
                Text("New Typography")
                    .foregroundStyle(.black)
                    .font(.title3.weight(.semibold))
            }
        }
    }
    
    var forEachTypographies: some View {
        ForEach(typographyManager.myTypographies.createdTypographies, id: \.name) { typography in
            ZStack {
                NavigationLink(destination: CreateAlphabetView(myFont: typography, fontName: typography.name)) {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(Color.white)
                            .frame(width: 387, height: 387)
                            .shadow(color: .black.opacity(0.3), radius: 7.5, y: 5)
                        HStack {
                            if typography.uppercaseDrawing != nil {
                                Image(uiImage: UIImage(data: typography.uppercaseDrawing!)!)
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                    
                            } else {
                                Text("A")
                                    .foregroundStyle(Color.ourLightGray)
                                    .font(.system(size: 250))
                            }
                            if typography.lowercaseDrawing != nil {
                                Image(uiImage: UIImage(data: typography.lowercaseDrawing!)!)
                                    .resizable()
                                    .frame(width: 150, height: 150)
                            } else {
                                Text("a")
                                    .foregroundStyle(Color.ourLightGray)
                                    .font(.system(size: 250))
                            }
                        }
                        VStack {
                            Spacer()
                            ZStack {
                                Text(typography.name)
                                    .font(.title2)
                                    .foregroundStyle(.black)
                                    .padding()
                                Spacer()
                                HStack {
                                    Spacer()
                                    if typography.isExported {
                                        Image(systemName: "checkmark.icloud.fill")
                                            .foregroundStyle(.black, .yellow)
                                            .font(.system(size: 24))
                                            .padding(.trailing, 30)
                                    } else {
                                        Image(systemName: "checkmark.icloud")
                                            .foregroundStyle(Color.ourGray)
                                            .font(.system(size: 24))
                                            .padding(.trailing, 30)
                                    }
                                }
                            }
                        }
                    }
                }
                optionsButton
            }
            .frame(width: 387, height: 387)
        }
    }
    
    var optionsButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    // opções da tipografia
                } label: {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "ellipsis.circle.fill")
                                .foregroundStyle(.black, .yellow)
                                .font(.system(size: 24))
                        }
                        Spacer()
                    }
                }
                .frame(width: 30, height: 30)
                .padding(30)
            }
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
