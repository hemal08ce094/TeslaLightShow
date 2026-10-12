//
//  ContentView.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ProjectViewModel()
    @State private var showingNewProjectSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Global Background
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.05, blue: 0.08), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ProjectListView(viewModel: viewModel, showingNewProjectSheet: $showingNewProjectSheet)
            }
        }
        .sheet(isPresented: $showingNewProjectSheet) {
            NewProjectSheet(viewModel: viewModel, isPresented: $showingNewProjectSheet)
        }
        .preferredColorScheme(.dark)
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
