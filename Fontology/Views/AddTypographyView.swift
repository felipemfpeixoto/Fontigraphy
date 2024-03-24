import SwiftUI

struct AddTypographyView: View {
    @EnvironmentObject var typographyManager: TypographyManager
    
    @Binding var isSheetPresented: Bool
    
    @State private var typographyName = ""
    
    var body: some View {
        ZStack {
            Color.ourLightGray
            VStack {
                Spacer()
                Text("Create new typography")
                    .font(.title)
                Spacer()
                TextField("", text: $typographyName)
                    .foregroundStyle(.black)
                    .background(.white)
                    .font(.system(size: 20))
                    .padding()
                Button {
                    // criar nova tipografia
                    typographyManager.addTypography(name: typographyName)
                } label: {
                    Text("Criar")
                        .font(.title)
                }
                Spacer()
                Button {
                    isSheetPresented.toggle()
                } label: {
                    Text("Fechar")
                }
                Spacer()
            }
        }
    }
    
}

//#Preview {
//    AddTypographyView()
//}
