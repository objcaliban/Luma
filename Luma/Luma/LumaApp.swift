//
//  LumaApp.swift
//  Luma
//
//  Created by Anastasiia Yefremova on 15.04.2026.
//

import SwiftUI

@main
struct LumaApp: App {
    /// - Note - possible improvement: introduce a DI container or environment-based injection
    ///   for better scoping and testability; simplified given the scope of the task
    @State private var viewModel = ChatViewModel()

    var body: some Scene {
        WindowGroup {
            ChatView(viewModel: viewModel)
        }
    }
}
