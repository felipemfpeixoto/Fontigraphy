import SwiftUI
import Lottie

struct ContentView: View {
    
    @State private var showImage = true

    var body: some View {
        NavigationStack {
            ZStack {
                if showImage {
                    Image("Carregamento")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                    VStack {
                        Spacer()
                        LottieAnimationViewRepresentable(animationName: "Composio 1")
                            .frame(width: 100, height: 100)
                            .padding(.bottom)
                    }
                    .padding(.bottom)
                       
                } else {
                    TutorialView()
//                    TypographiesView()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(Animation.easeInOut(duration: 0.75)) {
                    self.showImage.toggle()
                }
            }
        }
    }
}


struct LottieAnimationViewRepresentable: UIViewControllerRepresentable {
    let animationName: String
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = UIViewController()
        let view = LottieAnimationView(name: animationName)
        view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(view)
        view.heightAnchor.constraint(equalTo: vc.view.heightAnchor).isActive = true
        view.widthAnchor.constraint(equalTo: vc.view.widthAnchor).isActive = true
        view.loopMode = .loop
        view.play()
        return vc
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        ()
    }
}

#Preview {
    ContentView()
}
