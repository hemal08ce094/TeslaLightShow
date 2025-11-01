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
            ProjectListView(viewModel: viewModel, showingNewProjectSheet: $showingNewProjectSheet)
        }
        .sheet(isPresented: $showingNewProjectSheet) {
            NewProjectSheet(viewModel: viewModel, isPresented: $showingNewProjectSheet)
        }
    }
}

#Preview {
    ContentView()
}
