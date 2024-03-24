import SwiftUI

struct ContentView: View {
    @EnvironmentObject var typographyManager: TypographyManager
    
    @State var isPresentingAddTypography: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Text("Your Typographies")
                            .font(.title.weight(.bold))
                            .padding()
                        Spacer()
                    }
                    Spacer()
                    ScrollView(.horizontal) {
                        HStack(spacing: 20) {
                            Button {
                                // Botao para criar uma nova tipografia
                                isPresentingAddTypography.toggle()
                            } label: {
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(Color.ourLightGray)
                                        .frame(width: 387, height: 387)
                                    Image(systemName: "plus")
                                        .foregroundStyle(Color.ourGray)
                                        .font(.system(size: 100))
                                }
                                .padding(.leading, 100)
                            }
                            ForEach(typographyManager.myTypographies.createdTypographies, id: \.name) { typography in
                                NavigationLink(destination: CreateAlphabetView(fontName: typography.name)) {
                                    ZStack {
                                        Rectangle()
                                            .foregroundStyle(Color.ourLightGray)
                                            .frame(width: 387, height: 387)
                                        VStack {
                                            Spacer()
                                            Text(typography.name)
                                                .font(.title2)
                                                .padding()
                                        }
                                    }
                                    .frame(width: 387, height: 387)
                                }
                            }
                        }
                        .padding()
                    }
                    Spacer()
                }
//                NavigationLink(destination: CreateAlphabetView(fontName: "Teste")) {
//                    Text("Vai pra lá")
//                }
            }
        }
        .sheet(isPresented: $isPresentingAddTypography, content: {
            AddTypographyView(isSheetPresented: $isPresentingAddTypography)
        })
    }
}

#Preview {
    ContentView()
}
