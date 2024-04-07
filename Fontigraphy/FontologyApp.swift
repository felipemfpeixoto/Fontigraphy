//
//  FontologyApp.swift
//  Fontology
//
//  Created by infra on 24/03/24.
//

import SwiftUI

@main
struct FontologyApp: App {
    @StateObject var typographyManager = TypographyManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//            TypographiesView()
                .environmentObject(typographyManager)
        }
    }
}
