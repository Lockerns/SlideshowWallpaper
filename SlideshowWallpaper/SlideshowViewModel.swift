import Foundation
import Combine
import AVFoundation

enum MediaItem: Identifiable, Equatable {
    case image(URL)
    case video(URL)

    var id: String {
        switch self {
        case .image(let url): return "image:\(url.path)"
        case .video(let url): return "video:\(url.path)"
        }
    }

    var url: URL {
        switch self {
        case .image(let u): return u
        case .video(let u): return u
        }
    }
}

struct SlideshowConfig: Codable {
    var interval: TimeInterval = 5.0
    var shuffle: Bool = false
    var loop: Bool = true
    var videoPlaybackSpeed: Float = 1.0
}

class SlideshowViewModel: ObservableObject {
    @Published var items: [MediaItem] = []
    @Published var currentIndex: Int = 0
    @Published var isPlaying: Bool = true

    private var folderURL: URL?
    private var folderDescriptor: CInt = -1
    private var folderSource: DispatchSourceFileSystemObject?
    private var timerCancellable: AnyCancellable?
    private var config = SlideshowConfig()

    init() {
        // no-op
    }

    func openFolder(_ url: URL) {
        stopWatching()
        folderURL = url
        loadConfigIfExists()
        reloadItems()
        startWatching()
        startTimerIfNeeded()
    }

    func reloadItems() {
        guard let folderURL = folderURL else { return }
        let fm = FileManager.default
        let keys: [URLResourceKey] = [.isDirectoryKey, .nameKey]
        let enumerator = fm.enumerator(at: folderURL, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles, .skipsPackageDescendants])
        var found: [MediaItem] = []
        while let file = enumerator?.nextObject() as? URL {
            let path = file.path.lowercased()
            if path.hasSuffix(".jpg") || path.hasSuffix(".jpeg") || path.hasSuffix(".png") || path.hasSuffix(".heic") || path.hasSuffix(".gif") {
                found.append(.image(file))
            } else if path.hasSuffix(".mp4") || path.hasSuffix(".mov") || path.hasSuffix(".m4v") {
                found.append(.video(file))
            }
        }
        if config.shuffle {
            found.shuffle()
        }
        DispatchQueue.main.async {
            self.items = found
            if self.items.isEmpty {
                self.currentIndex = 0
            } else {
                self.currentIndex = min(self.currentIndex, max(0, self.items.count - 1))
            }
        }
    }

    func next() {
        guard !items.isEmpty else { return }
        currentIndex += 1
        if currentIndex >= items.count {
            if config.loop {
                currentIndex = 0
            } else {
                currentIndex = items.count - 1
                isPlaying = false
            }
        }
    }

    func previous() {
        guard !items.isEmpty else { return }
        currentIndex -= 1
        if currentIndex < 0 {
            if config.loop {
                currentIndex = items.count - 1
            } else {
                currentIndex = 0
            }
        }
    }

    func playPause() {
        isPlaying.toggle()
        startTimerIfNeeded()
    }

    private func startTimerIfNeeded() {
        timerCancellable?.cancel()
        guard isPlaying else { return }
        // Timer that ticks every `config.interval` seconds; if current item is video, timer won't advance until video ends.
        timerCancellable = Timer.publish(every: config.interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                // If current is video, do not auto-advance here (video controls advancement)
                if self.currentItemIsVideo() { return }
                self.next()
            }
    }

    func currentItem() -> MediaItem? {
        guard items.indices.contains(currentIndex) else { return nil }
        return items[currentIndex]
    }

    func currentItemIsVideo() -> Bool {
        if let it = currentItem() {
            if case .video = it { return true }
        }
        return false
    }

    // Called by video player when video finishes
    func videoDidFinish() {
        // advance to next
        DispatchQueue.main.async {
            self.next()
        }
    }

    // MARK: - Folder watching
    private func startWatching() {
        guard let folderURL = folderURL else { return }
        folderDescriptor = open(folderURL.path, O_EVTONLY)
        if folderDescriptor < 0 { return }
        folderSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: folderDescriptor, eventMask: .write, queue: DispatchQueue.main)
        folderSource?.setEventHandler { [weak self] in
            self?.reloadItems()
        }
        folderSource?.setCancelHandler { [weak self] in
            if let fd = self?.folderDescriptor, fd >= 0 {
                close(fd)
            }
            self?.folderDescriptor = -1
        }
        folderSource?.resume()
    }

    private func stopWatching() {
        folderSource?.cancel()
        folderSource = nil
        if folderDescriptor >= 0 {
            close(folderDescriptor)
            folderDescriptor = -1
        }
    }

    // MARK: - Config
    private func loadConfigIfExists() {
        guard let folderURL = folderURL else { return }
        let cfg = folderURL.appendingPathComponent("config.json")
        if FileManager.default.fileExists(atPath: cfg.path) {
            do {
                let data = try Data(contentsOf: cfg)
                let decoder = JSONDecoder()
                let c = try decoder.decode(SlideshowConfig.self, from: data)
                self.config = c
            } catch {
                print("Failed to read config.json: \(error)")
            }
        } else {
            self.config = SlideshowConfig()
        }
    }

    func currentVideoPlaybackSpeed() -> Float {
        return config.videoPlaybackSpeed
    }
}
