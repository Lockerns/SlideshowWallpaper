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
    let viewModel = SlideshowViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func appDidBecomeActive() {
        viewModel.reloadItems()
    }
}
