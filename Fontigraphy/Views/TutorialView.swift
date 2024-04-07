//
//  TutorialView.swift
//  Fontigraphy
//
//  Created by infra on 02/04/24.
//

import SwiftUI

struct TutorialView: View {
    
    @State var isShowingFirst: Bool = false
    @State var isShowingSecond: Bool = false
    
    var body: some View {
        ZStack {
            Image("Tutorial")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            if isShowingFirst {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.white)
                    VStack {
                        Spacer()
                        Text("Fontigraphy is an application that allows users to create their own fonts from their personal handwriting")
                            .font(.custom("Arial", size: 20))
                            .padding(.horizontal, 30)
                            .padding(.top)
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                // Mudar os valores das variáveis
                                withAnimation(Animation.spring(duration: 0.25)) {
                                    self.isShowingFirst.toggle()
                                    self.isShowingSecond.toggle()
                                }
                            } label: {
                                Text("Continue")
                                    .bold()
                            }
                        }
                        .padding()
                    }
                }
                .frame(width: 420, height: 187)
                .offset(x: 200, y: 200)
            }
            if isShowingSecond {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.white)
                    VStack {
                        Spacer()
                        Text("Using your finger or an Apple Pencil with the editing tools, you can share the fonts you've created for a variety of digital projects")
                            .font(.custom("Arial", size: 22))
                            .padding(.horizontal, 30)
                            .padding(.top)
                        Spacer()
                        HStack {
                            Spacer()
                            NavigationLink(destination: TypographiesView()) {
                                Text("Continue")
                                    .bold()
                            }
                        }
                        .padding()
                    }
                }
                .frame(width: 420, height: 218)
                .offset(x: -200, y: -150)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(Animation.spring(duration: 0.25)) {
                    self.isShowingFirst.toggle()
                }
            }
        }
    }
}

#Preview {
    TutorialView()
}
