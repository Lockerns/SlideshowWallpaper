import SwiftUI
import AVFoundation

struct AVPlayerContainerView: NSViewRepresentable {
    let url: URL
    let playbackSpeed: Float
    var onFinish: (() -> Void)?

    func makeNSView(context: Context) -> PlayerNSView {
        let v = PlayerNSView(frame: .zero)
        v.configure(url: url, speed: playbackSpeed, onFinish: onFinish)
        return v
    }

    func updateNSView(_ nsView: PlayerNSView, context: Context) {
        nsView.update(url: url, speed: playbackSpeed)
    }

    class PlayerNSView: NSView {
        private var player: AVPlayer?
        private var playerLayer: AVPlayerLayer?

        private var endObserver: Any?

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
        }

        required init?(coder decoder: NSCoder) {
            super.init(coder: decoder)
            wantsLayer = true
        }

        func configure(url: URL, speed: Float, onFinish: (() -> Void)?) {
            setupPlayer(url: url, speed: speed, onFinish: onFinish)
        }

        func update(url: URL, speed: Float) {
            // If same url, just update speed
            if player?.currentItem?.asset as? AVURLAsset == AVURLAsset(url: url) {
                player?.rate = speed * (player?.rate ?? 1.0)
                return
            }
            setupPlayer(url: url, speed: speed, onFinish: nil)
        }

        private func setupPlayer(url: URL, speed: Float, onFinish: (() -> Void)?) {
            // Clean up
            if let obs = endObserver {
                NotificationCenter.default.removeObserver(obs)
                endObserver = nil
            }
            playerLayer?.removeFromSuperlayer()
            player = AVPlayer(url: url)
            player?.actionAtItemEnd = .pause
            player?.rate = speed
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bounds
            playerLayer?.videoGravity = .resizeAspect
            if let layer = layer {
                layer.addSublayer(playerLayer!)
            } else {
                self.layer = CALayer()
                layer?.addSublayer(playerLayer!)
            }
            // Observe end
            endObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
                onFinish?()
            }
            player?.playImmediately(atRate: speed)
        }

        override func layout() {
            super.layout()
            playerLayer?.frame = bounds
        }

        deinit {
            if let obs = endObserver {
                NotificationCenter.default.removeObserver(obs)
            }
        }
    }
}
