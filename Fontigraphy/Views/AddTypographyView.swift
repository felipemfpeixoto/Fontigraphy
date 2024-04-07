import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct AddTypographyView: View {
    @EnvironmentObject var typographyManager: TypographyManager
    
    @Binding var isSheetPresented: Bool
    
    @State private var typographyName = ""
    
    var body: some View {
        ZStack {
            Color.begeDeCria
            VStack {
                Spacer()
            
                Text("Create new typography")
                    .font(.system(size: 32).weight(.bold))
                    
                Spacer()
                TextField("  Name your font...", text: $typographyName)
                    .foregroundStyle(.black)
                    .background(.white)
                    .border(Color.ourLightGray, width: 1)
                    .font(.system(size: 25))
                    .padding(.horizontal, 50)
                Spacer()
                HStack {
                    Button {
                        isSheetPresented.toggle()
                    } label: {
                        ZStack {
                            Rectangle()
                                .frame(width: 328, height: 100)
                                .foregroundStyle(Color.begeDeCria)
                                .border(Color.ourLightGray)
                            Text("Cancel")
                                .foregroundStyle(.black)
                        }
                        .padding(-10)
                    }
                    Button {
                        // criar nova tipografia
                        if typographyName != "" {
                            typographyManager.addTypography(name: typographyName)
                            isSheetPresented.toggle()
                            UIApplication.shared.endEditing()
                        }
                    } label: {
                        ZStack(alignment: .center) {
                            Rectangle()
                                .frame(width: 328, height: 100)
                                .border(Color.ourLightGray)
                                .foregroundStyle(Color.begeDeCria)
                            Text("Create")
                                .foregroundStyle(.black)
                                .font(.system(size: 20).weight(.semibold))
                        }
                        .padding(-5)
                    }
                }
            }
        }
        .onAppear {
            typographyName = ""
        }
        .frame(width: 644, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
    
}

//#Preview {
//    AddTypographyView()
//}
