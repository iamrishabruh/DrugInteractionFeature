//
//  DrugInteractionCheckerApp.swift
//  Drug Interaction Checker
//

import SwiftUI

@main
struct DrugInteractionCheckerApp: App {
    @StateObject private var viewModel = DrugInteractionViewModel(client: DrugInteractionViewModel.makeClient())

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
