import SwiftUI
import AppKit

// MARK: - Theme Enum

enum AppThemeMode: String, CaseIterable {
    case dark
    case light
}

// MARK: - Theme Colors

struct ThemeColors {
    // Terminal
    let terminalBackground: NSColor
    let terminalForeground: NSColor

    // Pane chrome
    let paneBackground: Color
    let titlebarBackground: Color
    let borderDim: Color

    // Workspace
    let workspaceBackground: Color

    // Text
    let titleFocused: Color
    let titleUnfocused: Color
    let exitCodeNormal: Color
    let buttonIcon: Color

    // Sidebar
    let sidebarSelectedBg: Color
    let sidebarHoveredBg: Color

    // ANSI 16 colors (for terminal)
    let ansiColors: [NSColor]
}

// MARK: - Theme Definitions

extension ThemeColors {
    static let dark = ThemeColors(
        terminalBackground: NSColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1),
        terminalForeground: NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1),
        paneBackground: Color(nsColor: NSColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1)),
        titlebarBackground: Color(nsColor: NSColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1)),
        borderDim: Color(nsColor: NSColor(red: 0.22, green: 0.22, blue: 0.24, alpha: 1)),
        workspaceBackground: Color(nsColor: NSColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1)),
        titleFocused: .white.opacity(0.9),
        titleUnfocused: .white.opacity(0.4),
        exitCodeNormal: .white.opacity(0.3),
        buttonIcon: .white.opacity(0.4),
        sidebarSelectedBg: Color.white.opacity(0.1),
        sidebarHoveredBg: Color.white.opacity(0.05),
        ansiColors: ThemeColors.darkANSI
    )

    static let light = ThemeColors(
        terminalBackground: NSColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1),
        terminalForeground: NSColor(red: 0.13, green: 0.13, blue: 0.15, alpha: 1),
        paneBackground: Color(nsColor: NSColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)),
        titlebarBackground: Color(nsColor: NSColor(red: 0.92, green: 0.92, blue: 0.93, alpha: 1)),
        borderDim: Color(nsColor: NSColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1)),
        workspaceBackground: Color(nsColor: NSColor(red: 0.89, green: 0.89, blue: 0.91, alpha: 1)),
        titleFocused: .black.opacity(0.85),
        titleUnfocused: .black.opacity(0.45),
        exitCodeNormal: .black.opacity(0.35),
        buttonIcon: .black.opacity(0.45),
        sidebarSelectedBg: Color.black.opacity(0.08),
        sidebarHoveredBg: Color.black.opacity(0.04),
        ansiColors: ThemeColors.lightANSI
    )

    // MARK: - ANSI Color Palettes

    /// Dark theme: standard terminal colors
    static let darkANSI: [NSColor] = [
        // Normal colors (0-7)
        NSColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1),  // black
        NSColor(red: 0.85, green: 0.30, blue: 0.30, alpha: 1),  // red
        NSColor(red: 0.30, green: 0.75, blue: 0.35, alpha: 1),  // green
        NSColor(red: 0.85, green: 0.75, blue: 0.30, alpha: 1),  // yellow
        NSColor(red: 0.40, green: 0.55, blue: 0.95, alpha: 1),  // blue
        NSColor(red: 0.75, green: 0.40, blue: 0.85, alpha: 1),  // magenta
        NSColor(red: 0.30, green: 0.80, blue: 0.80, alpha: 1),  // cyan
        NSColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 1),  // white
        // Bright colors (8-15)
        NSColor(red: 0.45, green: 0.45, blue: 0.50, alpha: 1),  // bright black
        NSColor(red: 1.00, green: 0.40, blue: 0.40, alpha: 1),  // bright red
        NSColor(red: 0.40, green: 0.90, blue: 0.45, alpha: 1),  // bright green
        NSColor(red: 1.00, green: 0.90, blue: 0.40, alpha: 1),  // bright yellow
        NSColor(red: 0.55, green: 0.70, blue: 1.00, alpha: 1),  // bright blue
        NSColor(red: 0.90, green: 0.55, blue: 1.00, alpha: 1),  // bright magenta
        NSColor(red: 0.45, green: 0.95, blue: 0.95, alpha: 1),  // bright cyan
        NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1),  // bright white
    ]

    /// Light theme: darkened ANSI colors optimized for white background
    static let lightANSI: [NSColor] = [
        // Normal colors (0-7) — darkened for readability on white
        NSColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1),  // black
        NSColor(red: 0.75, green: 0.05, blue: 0.05, alpha: 1),  // red (deep)
        NSColor(red: 0.10, green: 0.52, blue: 0.10, alpha: 1),  // green (forest)
        NSColor(red: 0.55, green: 0.42, blue: 0.00, alpha: 1),  // yellow (dark gold)
        NSColor(red: 0.10, green: 0.20, blue: 0.72, alpha: 1),  // blue (deep)
        NSColor(red: 0.62, green: 0.08, blue: 0.52, alpha: 1),  // magenta (deep)
        NSColor(red: 0.00, green: 0.45, blue: 0.50, alpha: 1),  // cyan (teal)
        NSColor(red: 0.45, green: 0.45, blue: 0.47, alpha: 1),  // white → gray
        // Bright colors (8-15) — slightly lighter but still readable
        NSColor(red: 0.35, green: 0.35, blue: 0.38, alpha: 1),  // bright black
        NSColor(red: 0.88, green: 0.15, blue: 0.15, alpha: 1),  // bright red
        NSColor(red: 0.15, green: 0.62, blue: 0.15, alpha: 1),  // bright green
        NSColor(red: 0.68, green: 0.52, blue: 0.00, alpha: 1),  // bright yellow
        NSColor(red: 0.20, green: 0.35, blue: 0.85, alpha: 1),  // bright blue
        NSColor(red: 0.75, green: 0.18, blue: 0.65, alpha: 1),  // bright magenta
        NSColor(red: 0.05, green: 0.55, blue: 0.60, alpha: 1),  // bright cyan
        NSColor(red: 0.25, green: 0.25, blue: 0.28, alpha: 1),  // bright white → dark gray
    ]

    // MARK: - Helper

    static func colors(for mode: AppThemeMode) -> ThemeColors {
        switch mode {
        case .dark: return .dark
        case .light: return .light
        }
    }
}
