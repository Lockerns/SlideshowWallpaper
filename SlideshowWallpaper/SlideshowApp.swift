import SwiftUI
import AppKit

@main
struct SlideshowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.viewModel)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let viewModel = SlideshowViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create a borderless window and host SwiftUI content
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        window = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .normal // keep normal; you can set to .desktop or custom if needed
        window.collectionBehavior = [.fullScreenPrimary, .canJoinAllSpaces]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true

        // Make window ignore mouse (optional) - here we want it interactive so keep default
        window.makeKeyAndOrderFront(nil)

        // Host SwiftUI view
        let contentView = ContentView().environmentObject(viewModel)
        window.contentView = NSHostingView(rootView: contentView)

        // Observe when the app becomes active to refresh
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func appDidBecomeActive() {
        viewModel.reloadItems()
    }
}
