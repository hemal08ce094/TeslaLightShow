import SwiftUI
import AVKit

struct LightShowDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isSharePresented: Bool = false
    @State private var selectedShowIndex: Int = 0

    let allShows: [LightShow]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Horizontal picker for shows
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(allShows.indices, id: \.self) { index in
                            Button {
                                selectedShowIndex = index
                            } label: {
                                Text("Show\(index + 1)")
                                    .fontWeight(selectedShowIndex == index ? .bold : .regular)
                                    .foregroundColor(selectedShowIndex == index ? Color.teslaBlue(for: colorScheme) : Color.secondary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(selectedShowIndex == index ? Color.teslaBlue(for: colorScheme) : Color.secondary.opacity(0.3), lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                let lightShow = allShows[selectedShowIndex]

                if let videoURL = Bundle.main.url(forResource: lightShow.video.components(separatedBy: ".").first, withExtension: lightShow.video.components(separatedBy: ".").last) {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(height: 220)
                        .cornerRadius(16)
                        .shadow(color: Color.neonShadow(for: colorScheme).opacity(0.7), radius: 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.neonAccent(for: colorScheme), lineWidth: 2)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 220)
                        .overlay(
                            Text("Video Not Found")
                                .foregroundColor(.secondary)
                        )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(lightShow.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.labelSingle(for: colorScheme))

                    Text(lightShow.description)
                        .font(.body)
                        .foregroundColor(Color.labelSingle(for: colorScheme).opacity(0.85))
                }
                .padding(.horizontal)

                HStack(spacing: 20) {
                    Button {
                        isSharePresented = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.down.zip")
                            Text("Export Zip")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teslaBlue(for: colorScheme))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: Color.teslaBlue(for: colorScheme).opacity(0.7), radius: 8, x: 0, y: 3)
                    }
                }
                .padding(.horizontal)

                Link(destination: URL(string: lightShow.steps)!) {
                    HStack(spacing: 8) {
                        Text("Export Steps")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.teslaBlue(for: colorScheme))
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(Color.teslaBlue(for: colorScheme))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.teslaBlue(for: colorScheme), lineWidth: 1.8)
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 24)
        }
        .navigationTitle(allShows[selectedShowIndex].title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.neonBackground(for: colorScheme).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isSharePresented = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share Light Show")
            }
        }
        .sheet(isPresented: $isSharePresented) {
            let lightShow = allShows[selectedShowIndex]
            if let url = Bundle.main.url(forResource: lightShow.zipFile.components(separatedBy: ".").first, withExtension: lightShow.zipFile.components(separatedBy: ".").last) {
                ActivityView(activityItems: [url])
            } else {
                ActivityView(activityItems: ["\(lightShow.title) Zip file not found."])
            }
        }
    }
}

#Preview {
    LightShowDetailView(
        allShows: [
            LightShow(
                title: "Tesla Light Show 1",
                description: "Demo the iconic Tesla light show synced with music and vibrant colors.",
                thumbnail: "circle",
                video: "TLightShow/TeslaLightShows/Show1/Show1.mp4",
                zipFile: "tesla_show1.zip",
                steps: "https://www.tesla.com/support/tesla-light-show"
            ),
            LightShow(
                title: "Tesla Light Show 2",
                description: "Experience the beautiful choreography of Tesla's light show 2.",
                thumbnail: "circle",
                video: "TLightShow/TeslaLightShows/Show2/Show2.mp4",
                zipFile: "tesla_show2.zip",
                steps: "https://www.tesla.com/support/tesla-light-show"
            ),
            LightShow(
                title: "Tesla Light Show 3",
                description: "A dynamic light show filled with stunning effects and beat drops.",
                thumbnail: "circle",
                video: "TLightShow/TeslaLightShows/Show3/Show3.mp4",
                zipFile: "tesla_show3.zip",
                steps: "https://www.tesla.com/support/tesla-light-show"
            ),
            LightShow(
                title: "Tesla Light Show 4",
                description: "An electrifying performance of Tesla's fourth light show edition.",
                thumbnail: "circle",
                video: "TLightShow/TeslaLightShows/Show4/Show4.mp4",
                zipFile: "tesla_show4.zip",
                steps: "https://www.tesla.com/support/tesla-light-show"
            ),
            LightShow(
                title: "Tesla Light Show 5",
                description: "Immerse yourself in the vibrant Tesla light show number five.",
                thumbnail: "circle",
                video: "TLightShow/TeslaLightShows/Show5/Show5.mp4",
                zipFile: "tesla_show5.zip",
                steps: "https://www.tesla.com/support/tesla-light-show"
            ),
            LightShow(
                title: "Tesla Light Show 6",
                description: "The grand Tesla light show finale with dazzling lights and music.",
                thumbnail: "circle",
                video: "TLightShow/TeslaLightShows/Show6/Show6.mp4",
                zipFile: "tesla_show6.zip",
                steps: "https://www.tesla.com/support/tesla-light-show"
            )
        ]
    )
}

struct ActivityView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIActivityViewController

    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ActivityView(activityItems: ["Sample Share Item"])
}
