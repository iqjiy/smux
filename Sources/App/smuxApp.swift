import SwiftUI

@main
struct smuxApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var workspaceManager = WorkspaceManager()
    @StateObject private var activityDetector = ActivityDetector()
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workspaceManager)
                .environmentObject(activityDetector)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentMode == .dark ? .dark : .light)
                .onAppear {
                    guard !workspaceManager.hasInitialized else { return }
                    workspaceManager.hasInitialized = true

                    themeManager.applyAppearance()
                    activityDetector.start(workspaceManager: workspaceManager)
                    PersistenceManager.shared.restore(into: workspaceManager)
                    // Autosave every 30 seconds
                    Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak workspaceManager] _ in
                        guard let manager = workspaceManager else { return }
                        Task { @MainActor in
                            PersistenceManager.shared.save(workspaceManager: manager)
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
                    PersistenceManager.shared.save(workspaceManager: workspaceManager)
                }
        }
        .commands {
            AppCommands(workspaceManager: workspaceManager, themeManager: themeManager)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
    }
}
