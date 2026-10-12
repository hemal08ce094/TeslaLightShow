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
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.projects.isEmpty {
                    emptyStateView
                } else {
                    ForEach(viewModel.projects) { project in
                        NavigationLink(destination: ProjectEditorView(viewModel: viewModel, project: project)) {
                            ProjectCardView(project: project)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.deleteProject(project)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Tesla Light Shows")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingNewProjectSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.5), radius: 10)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 100)
            
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                
                Image(systemName: "bolt.car.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: .blue.opacity(0.5), radius: 10)
            }

            VStack(spacing: 8) {
                Text("No Light Shows")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Create your first Tesla light show\nand make your car dance!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }

            Button(action: {
                showingNewProjectSheet = true
            }) {
                Text("Create New Project")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(25)
                    .shadow(color: .blue.opacity(0.5), radius: 10)
            }
            .padding(.top, 20)
        }
    }
}

struct ProjectCardView: View {
    let project: LightShowProject

    var body: some View {
        HStack {
            // Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "music.note.list")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if !project.audioFileName.isEmpty {
                    Text(project.audioFileName)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                } else {
                    Text("No audio")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.5))
                }
                
                HStack(spacing: 12) {
                    Label("\(project.frames.count) frames", systemImage: "sparkles")
                    Label(project.modifiedDate.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                }
                .font(.caption2)
                .foregroundColor(.gray.opacity(0.8))
                .padding(.top, 4)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct NewProjectSheet: View {
    @ObservedObject var viewModel: ProjectViewModel
    @Binding var isPresented: Bool
    @State private var projectName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.12).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Project Name")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .textCase(.uppercase)
                        
                        TextField("Enter name", text: $projectName)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("New Light Show")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        if !projectName.isEmpty {
                            viewModel.createNewProject(name: projectName)
                            isPresented = false
                        }
                    }
                    .disabled(projectName.isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
    }
}
