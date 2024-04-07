//
//  TypographiesView.swift
//  Fontigraphy
//
//  Created by infra on 02/04/24.
//

import SwiftUI

struct TypographiesView: View {
    
    @EnvironmentObject var typographyManager: TypographyManager
    
    @State var isPresentingAddTypography: Bool = false
    
    @State var showingActionSheet = false
    
    var body: some View {
        ZStack {
            Color.white
            VStack {
                Spacer()
                Image("mainBackground")
                    .resizable()
                    .scaledToFit()
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
            if isPresentingAddTypography {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
            }
            AddTypographyView(isSheetPresented: $isPresentingAddTypography)
                .padding(.top, 100)
                .offset(y: isPresentingAddTypography ? 0 : UIScreen.main.bounds.height)
                .animation(.spring())
        }
        .navigationBarBackButtonHidden()
    }
    
    var mainHeader: some View {
        HStack {
            Text("Your Typographies")
                .font(.system(size: 48).weight(.bold))
                .padding(.leading, 120)
            Spacer()
            NavigationLink(destination: TutorialView()) {
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
            RoundedRectangle(cornerRadius: 13)
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
                        RoundedRectangle(cornerRadius: 13)
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
                            }
                        }
                    }
                }
                optionsButton
            }
            .frame(width: 387, height: 387)
            .alert("Are you sure you want to delete the \(typography.name) typography?", isPresented: $showingActionSheet, actions: {
                Button(role: .destructive) {
                    typographyManager.deleteTypography(name: typography.name)
                } label: {
                    Text("Delete")
                }
            })
        }
    }
    
    var optionsButton: some View {
        VStack {
            HStack {
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        showingActionSheet = true
                    } label: {
                        Text("Delete")
                    }
                } label: {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "trash.circle.fill")
                                .foregroundStyle(.black, .yellow)
                                .font(.system(size: 40))
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
    TypographiesView()
}
