import SwiftUI
import AppKit

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @AppStorage("appThemeMode") private var storedMode: String = AppThemeMode.dark.rawValue

    @Published var currentMode: AppThemeMode = .dark {
        didSet {
            storedMode = currentMode.rawValue
            applyAppearance()
        }
    }

    var colors: ThemeColors {
        ThemeColors.colors(for: currentMode)
    }

    private init() {
        // Restore from UserDefaults
        if let mode = AppThemeMode(rawValue: storedMode) {
            currentMode = mode
        }
    }

    func toggle() {
        currentMode = (currentMode == .dark) ? .light : .dark
    }

    func applyAppearance() {
        switch currentMode {
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        }
    }
}
