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
                    VStack {
                        Spacer()
                        ScrollView {
                            Text("Fontigraphy is an application that allows users to create their own fonts from their personal handwriting")
                                .font(Font.title)
                                .padding(.horizontal, 30)
                                .padding(.top)
                        }
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
                                    .font(.headline)
                                    .bold()
                            }
                        }
                        .padding()
                    }
                    .frame(width: 500, height: 250)
                }
                .background {
                    RoundedRectangle(cornerRadius: 13)
                        .foregroundStyle(.white)
                }
                .offset(x: 200, y: 200)
            }
            if isShowingSecond {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.white)
                    VStack {
                        Spacer()
                        ScrollView {
                            Text("Using your finger or an Apple Pencil with the editing tools, you can share the fonts you've created for a variety of digital projects")
                                .font(.title)
                                .padding(.horizontal, 30)
                                .padding(.top)
                        }
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
                .frame(width: 550, height: 250)
                .offset(x: 200, y: 200)
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
