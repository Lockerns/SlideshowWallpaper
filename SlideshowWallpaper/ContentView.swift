import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject var viewModel: SlideshowViewModel
    @State private var showControls: Bool = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let item = viewModel.currentItem() {
                switch item {
                case .image(let url):
                    ZoomableImageView(imageURL: url)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.6), value: viewModel.currentIndex)
                case .video(let url):
                    AVPlayerContainerView(url: url, playbackSpeed: viewModel.currentVideoPlaybackSpeed(), onFinish: {
                        viewModel.videoDidFinish()
                    })
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.6), value: viewModel.currentIndex)
                }
            } else {
                Text("No media found. Click Open Folder to choose a folder with images/videos.")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            // Controls overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: { openFolder() }) {
                        Image(systemName: "folder")
                            .padding(8)
                    }.help("Open Folder")
                    Button(action: { viewModel.playPause() }) {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .padding(8)
                    }.help("Play / Pause")
                    Button(action: { viewModel.previous() }) {
                        Image(systemName: "backward.fill")
                            .padding(8)
                    }.help("Previous")
                    Button(action: { viewModel.next() }) {
                        Image(systemName: "forward.fill")
                            .padding(8)
                    }.help("Next")
                    Spacer()
                }
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
        }
        .onAppear {
            // intentionally empty
        }
    }

    func openFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.begin { resp in
            if resp == .OK, let url = panel.url {
                viewModel.openFolder(url)
            }
        }
    }
}

// Simple image view that scales proportionally and supports pinch zoom via MagnificationGesture
struct ZoomableImageView: View {
    let imageURL: URL
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        if let nsImage = NSImage(contentsOf: imageURL) {
            GeometryReader { proxy in
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .scaleEffect(scale)
                    .gesture(MagnificationGesture()
                                .onChanged { v in
                                    scale = lastScale * v
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                }
                    )
            }
        } else {
            Color.gray
        }
    }
}
