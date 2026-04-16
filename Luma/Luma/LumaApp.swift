//
//  LumaApp.swift
//  Luma
//
//  Created by Anastasiia Yefremova on 15.04.2026.
//

import SwiftUI

@main
struct LumaApp: App {
    @State private var viewModel = ChatViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
