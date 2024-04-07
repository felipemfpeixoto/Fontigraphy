//
//  ToggleStyle.swift
//  Fontigraphy
//
//  Created by infra on 04/04/24.
//

import Foundation
import SwiftUI

struct MyToggleStyle: ToggleStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Rectangle()
                .foregroundColor(configuration.isOn ? .yellow : .gray)
                .frame(width: 51, height: 31, alignment: .center)
                .overlay(
                    Circle()
                        .foregroundColor(.black)
                        .overlay(
                            Text("Aa")
                                .font(.system(size: 15).weight(.bold))
                                .foregroundColor(.yellow)
                        )
                        .offset(x: configuration.isOn ? 11 : -11, y: 0)
                        .animation(Animation.linear(duration: 0.1))
                        
                ).cornerRadius(20)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
    
}
