//
//  ContentView.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import SwiftUI
import UIKit
import AVKit

//import LightShowDetailView
//import TutorialView
//import AboutView

// MARK: - Model

struct LightShow: Identifiable {
    let id: UUID = UUID()
    let title: String
    let description: String
    let thumbnail: String
    let video: String
    let zipFile: String
    let steps: String
}

// MARK: - Glassmorphism Modifier and BlurView for reusable blurred backgrounds

extension View {
    func glassBackground(cornerRadius: CGFloat = 20) -> some View {
        self.background(
            BlurView(style: .systemUltraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .opacity(0.8)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1.2)
                )
        )
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// Tesla-inspired color tokens for consistent theming
// For production, prefer managing these in an Asset Catalog for better maintainability and support for Dark/Light mode
extension Color {
    static var neonBackground: Color {
        Color("NeonBackground")
    }
    static var neonAccent: Color {
        Color("NeonAccent")
    }
    static var neonText: Color {
        Color("NeonText")
    }
    static var neonShadow: Color {
        Color("NeonShadow")
    }
}

// Fallback colors if asset catalog colors are not available, using colorScheme
extension Color {
    static func neonBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.08, green: 0.08, blue: 0.10) : Color.white
    }
    static func neonAccent(for colorScheme: ColorScheme) -> Color {
        Color(red: 0.91, green: 0.13, blue: 0.15)
    }
    static func teslaBlue(for colorScheme: ColorScheme) -> Color {
        Color(red: 0.10, green: 0.35, blue: 0.95)
    }
    static func neonText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : Color(red: 0.08, green: 0.08, blue: 0.10)
    }
    static func neonShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.85, green: 0.85, blue: 0.88) : Color.gray.opacity(0.3)
    }
    // Added single label color token per instructions
    static func labelSingle(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : Color(red: 0.12, green: 0.13, blue: 0.15)
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.neonBackground.ignoresSafeArea()
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                TutorialView()
                    .tabItem {
                        Image(systemName: "book")
                        Text("Tutorial")
                    }
                AboutView()
                    .tabItem {
                        Image(systemName: "info.circle")
                        Text("About")
                    }
            }
            .onAppear {
                if let resourcePath = Bundle.main.resourcePath {
                    let fileManager = FileManager.default
                    if let resourceContents = try? fileManager.subpathsOfDirectory(atPath: resourcePath) {
                        print("=== Bundle Resource List (with absolute paths) ===")
                        resourceContents.forEach { relativePath in
                            let absolutePath = (resourcePath as NSString).appendingPathComponent(relativePath)
                            print(absolutePath)
                        }
                        print("=== End Bundle Resource List ===")
                    }
                }
                let appearance = UITabBarAppearance()
                // Apply a frosted glass blur effect
                appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
                // Add a semi-transparent custom color for subtle tint (adjust RGBA as desired)
                appearance.backgroundColor = UIColor { trait in
                    trait.userInterfaceStyle == .dark ? UIColor(white: 0.12, alpha: 0.66) : UIColor(white: 1, alpha: 0.33)
                }
                UITabBar.appearance().standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }
        }
    }
}

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
   
    let shows: [LightShow] = [
        LightShow(
            title: "Tesla Light Show",
            description: "Experience the iconic Tesla light show synced perfectly with music and vibrant colors that dazzle and mesmerize.",
            thumbnail: "circle", // Using SF Symbol name for sample thumbnail
            video: "TLightShow/TeslaLightShows/Show1/Show1.mp4", // Local video file in bundle
            zipFile: "tesla_show.zip",
            steps: "https://www.tesla.com/support/tesla-light-show"
        ),
        LightShow(
            title: "Tesla Light Show",
            description: "Experience the iconic Tesla light show synced perfectly with music and vibrant colors that dazzle and mesmerize.",
            thumbnail: "circle", // Using SF Symbol name for sample thumbnail
            video: "TLightShow/TeslaLightShows/Show2/Show2.mp4", // Local video file in bundle
            zipFile: "tesla_show.zip",
            steps: "https://www.tesla.com/support/tesla-light-show"
        ),
        LightShow(
            title: "Tesla Light Show",
            description: "Experience the iconic Tesla light show synced perfectly with music and vibrant colors that dazzle and mesmerize.",
            thumbnail: "circle", // Using SF Symbol name for sample thumbnail
            video: "TLightShow/TeslaLightShows/Show3/Show3.mp4", // Local video file in bundle
            zipFile: "tesla_show.zip",
            steps: "https://www.tesla.com/support/tesla-light-show"
        ),
        LightShow(
            title: "Tesla Light Show",
            description: "Experience the iconic Tesla light show synced perfectly with music and vibrant colors that dazzle and mesmerize.",
            thumbnail: "circle", // Using SF Symbol name for sample thumbnail
            video: "TLightShow/TeslaLightShows/Show4/Show4.mp4", // Local video file in bundle
            zipFile: "tesla_show.zip",
            steps: "https://www.tesla.com/support/tesla-light-show"
        ),
        LightShow(
            title: "Tesla Light Show",
            description: "Experience the iconic Tesla light show synced perfectly with music and vibrant colors that dazzle and mesmerize.",
            thumbnail: "circle", // Using SF Symbol name for sample thumbnail
            video: "TLightShow/TeslaLightShows/Show5/Show5.mp4", // Local video file in bundle
            zipFile: "tesla_show.zip",
            steps: "https://www.tesla.com/support/tesla-light-show"
        ),
        LightShow(
            title: "Tesla Light Show",
            description: "Experience the iconic Tesla light show synced perfectly with music and vibrant colors that dazzle and mesmerize.",
            thumbnail: "circle", // Using SF Symbol name for sample thumbnail
            video: "TLightShow/TeslaLightShows/Show6/Show6.mp4", // Local video file in bundle
            zipFile: "tesla_show.zip",
            steps: "https://www.tesla.com/support/tesla-light-show"
        )
        
    ]

    let columns = [
        GridItem(.flexible()), GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.neonBackground(for: colorScheme).ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 28) {
                            ForEach(shows) { show in
                                NavigationLink(destination: LightShowDetailView(lightShow: show)) {
                                    NeonShowCard(lightShow: show)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                }
            }
            .navigationTitle("Tesla Light Shows")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundColor(Color.labelSingle(for: colorScheme))
                            .shadow(color: Color.neonShadow(for: colorScheme), radius: 7)
                    }
                }
            }
        }
    }
}

// Add these supporting views after AboutView

struct NeonFilterButton: View {
    @Environment(\.colorScheme) var colorScheme

    var title: String
    var systemImage: String
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(Color.labelSingle(for: colorScheme))
            Image(systemName: systemImage)
                .font(.subheadline)
                .foregroundColor(Color.neonAccent(for: colorScheme))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
//        .glassBackground(cornerRadius: 14)
    }
}

struct NeonShowCard: View {
    @Environment(\.colorScheme) var colorScheme

    var lightShow: LightShow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
//                    .glassBackground(cornerRadius: 18)
                if let uiImage = UIImage(systemName: lightShow.thumbnail) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 66, height: 66)
                        .foregroundColor(Color.neonAccent(for: colorScheme))
                        .shadow(color: Color.neonShadow(for: colorScheme).opacity(0.7), radius: 12)
                } else {
                    Image(systemName: lightShow.thumbnail)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 66, height: 66)
                        .foregroundColor(Color.neonAccent(for: colorScheme))
                        .shadow(color: Color.neonShadow(for: colorScheme).opacity(0.7), radius: 12)
                }
            }
            .frame(height: 120)
            Text(lightShow.title)
                .font(.headline)
                .foregroundColor(Color.labelSingle(for: colorScheme))
        }
        .padding(8)
    }
}

#Preview {
    ContentView()
}
