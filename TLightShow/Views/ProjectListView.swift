//
//  ProjectListView.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import SwiftUI

struct ProjectListView: View {
    @ObservedObject var viewModel: ProjectViewModel
    @Binding var showingNewProjectSheet: Bool

    var body: some View {
        List {
            ForEach(viewModel.projects) { project in
                NavigationLink(destination: ProjectEditorView(viewModel: viewModel, project: project)) {
                    ProjectRowView(project: project)
                }
            }
            .onDelete(perform: deleteProjects)
        }
        .navigationTitle("Tesla Light Shows")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingNewProjectSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if viewModel.projects.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "bolt.car.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    Text("No Light Shows")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Create your first Tesla light show")
                        .foregroundColor(.secondary)
                    Button("Create New Project") {
                        showingNewProjectSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    private func deleteProjects(at offsets: IndexSet) {
        offsets.forEach { index in
            let project = viewModel.projects[index]
            viewModel.deleteProject(project)
        }
    }
}

struct ProjectRowView: View {
    let project: LightShowProject

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.name)
                .font(.headline)

            HStack {
                if !project.audioFileName.isEmpty {
                    Label(project.audioFileName, systemImage: "music.note")
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                Spacer()

                Text("\(project.frames.count) frames")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text("Modified: \(project.modifiedDate, style: .relative) ago")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct NewProjectSheet: View {
    @ObservedObject var viewModel: ProjectViewModel
    @Binding var isPresented: Bool
    @State private var projectName = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Details")) {
                    TextField("Project Name", text: $projectName)
                }
            }
            .navigationTitle("New Light Show")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        if !projectName.isEmpty {
                            viewModel.createNewProject(name: projectName)
                            isPresented = false
                        }
                    }
                    .disabled(projectName.isEmpty)
                }
            }
        }
    }
}
