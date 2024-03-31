//
//  ExportView.swift
//  Fontology
//
//  Created by infra on 29/03/24.
//

import SwiftUI

struct ExportView: View {
    
    @Binding var isPresenting: Bool
    
    @Binding var isLoading: Bool
    
    let typography: Typography
    
    let fileName: String
    
    var documentsDirectory: URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            Image("Camada")
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 997, height: 632)
                    .foregroundStyle(.regularMaterial)
                if isLoading {
                    ProgressView()
                        .controlSize(.extraLarge)
                }
                else {
                    HStack {
                        Spacer()
                        ZStack {
                            Rectangle()
                                .frame(width: 460, height: 460)
                                .foregroundStyle(.white)
                                .shadow(radius: 20)
                            HStack {
                                if typography.uppercaseDrawing != nil {
                                    Image(uiImage: UIImage(data: typography.uppercaseDrawing!)!)
                                        .resizable()
                                        .frame(width: 150, height: 150)
                                        
                                }
                                if typography.lowercaseDrawing != nil {
                                    Image(uiImage: UIImage(data: typography.lowercaseDrawing!)!)
                                        .resizable()
                                        .frame(width: 150, height: 150)
                                }
                            }
                            .frame(width: 460, height: 460)
                        }
                        Spacer()
                        VStack {
                            Text(typography.name)
                                .font(.system(size: 64).weight(.bold))
                            Text("Share your TTF file with other people by clicking the button bellow")
                                .frame(width: 300)
                                .multilineTextAlignment(.center)
                            ShareLink(item: documentsDirectory.appendingPathComponent(fileName)) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 100)
                                        .frame(width: 207, height: 70)
                                        .foregroundStyle(.yellow)
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 30).weight(.semibold))
                                        Text("Share TTF")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 20))
                                    }
                                }
                            }
                            Button(action: {
                                isPresenting.toggle()
                            }, label: {
                                Text("Close")
                            })
                        }
                        Spacer()
                    }
                }
            }
            .frame(width: 997, height: 632)
        }
    }
}

//#Preview {
//    ExportView(typography: Typography(name: "MinhaFonte", characters: []), fileName: "")
//}
