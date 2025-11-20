import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject var viewModel: SlideshowViewModel
    
    @State private var showControls: Bool = true
    @State private var inactivityTask: Task<Void, Never>?
    
    private let inactivityTimeout: TimeInterval = 4.0
    
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
                    AVPlayerContainerView(url: url,
                                          playbackSpeed: viewModel.currentVideoPlaybackSpeed(),
                                          onFinish: { viewModel.videoDidFinish() })
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.6), value: viewModel.currentIndex)
                }
            } else {
                Text("No media found. Click Open Folder to choose a folder with images/videos.")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            // 控制按钮层
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
            .cornerRadius(12)
            .padding()
            .opacity(showControls ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: showControls)
            // 点击任意位置都重新显示控制栏
            .contentShape(Rectangle())
            .onTapGesture {
                restartInactivityTimer()
            }
        }
        // 鼠标悬停检测（macOS）
        .onHover { isHovering in
            if isHovering {
                showControls = true
                restartInactivityTimer()
            } else {
                restartInactivityTimer()   // 鼠标离开后也开始计时隐藏
            }
        }
        .onAppear {
            restartInactivityTimer()
        }
    }
    
    // MARK: - 打开文件夹
    func openFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.openFolder(url)
        }
    }
    
    // MARK: - 自动隐藏控制栏的核心逻辑
    private func restartInactivityTimer() {
        inactivityTask?.cancel()
        showControls = true
        inactivityTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(inactivityTimeout))
                if !Task.isCancelled {
                    withAnimation {
                        showControls = false
                    }
                }
            } catch {
            }
        }
    }
}

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

