import SwiftUI
import SwiftTerm
import Darwin

struct TerminalSurfaceView: NSViewRepresentable {
    @EnvironmentObject var themeManager: ThemeManager
    let panel: TerminalPanel
    let isFocused: Bool
    let isWorkspaceSelected: Bool
    var suppressFocus: Bool = false

    func makeCoordinator() -> Coordinator {
        Coordinator(panel: panel)
    }

    func makeNSView(context: Context) -> NSView {
        // Reuse existing terminal view if the panel already has one (survives workspace switches)
        if let existing = panel.terminalView as? SmuxTerminalView {
            context.coordinator.terminalView = existing
            applyTheme(to: existing)
            return existing
        }

        let tv = SmuxTerminalView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        tv.panel = panel
        tv.processDelegate = context.coordinator
        context.coordinator.terminalView = tv

        // Apply theme colors
        tv.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        applyTheme(to: tv)

        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        let home = ProcessInfo.processInfo.environment["HOME"] ?? NSHomeDirectory()
        let cwd = panel.workingDirectory ?? home

        var env = Terminal.getEnvironmentVariables(termName: "xterm-256color")
        env.append("LANG=en_US.UTF-8")

        tv.startProcess(executable: shell, args: [], environment: env, execName: nil, currentDirectory: cwd)

        // Replay saved scrollback from previous session
        if let scrollback = panel.scrollbackToRestore {
            panel.scrollbackToRestore = nil
            let lines = scrollback.components(separatedBy: "\n")
            let crlfText = lines.joined(separator: "\r\n")
            tv.feed(text: crlfText + "\r\n")
        }

        // Store on panel so it survives SwiftUI lifecycle
        panel.terminalView = tv

        return tv
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // Re-apply theme on every update (handles live theme switching)
        if let tv = nsView as? SmuxTerminalView {
            applyTheme(to: tv)
        }

        if isFocused && isWorkspaceSelected && !panel.isRenaming && !suppressFocus {
            DispatchQueue.main.async {
                if let window = nsView.window, window.firstResponder !== nsView {
                    window.makeFirstResponder(nsView)
                }
            }
        }
    }

    private func applyTheme(to tv: SmuxTerminalView) {
        let colors = themeManager.colors
        tv.nativeBackgroundColor = colors.terminalBackground
        tv.nativeForegroundColor = colors.terminalForeground

        // Apply ANSI color palette using SwiftTerm's Color type (16-bit RGB)
        let ansi = colors.ansiColors
        if ansi.count == 16 {
            let swiftTermColors: [SwiftTerm.Color] = ansi.map { nsColor in
                let c = nsColor.usingColorSpace(.sRGB) ?? nsColor
                return SwiftTerm.Color(
                    red: UInt16(c.redComponent * 65535),
                    green: UInt16(c.greenComponent * 65535),
                    blue: UInt16(c.blueComponent * 65535)
                )
            }
            tv.installColors(swiftTermColors)
        }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, LocalProcessTerminalViewDelegate {
        let panel: TerminalPanel
        weak var terminalView: SmuxTerminalView?

        init(panel: TerminalPanel) {
            self.panel = panel
        }

        func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

        func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
            Task { @MainActor in
                self.panel.recordTitleChange(title)
            }
        }

        func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
            Task { @MainActor in
                self.panel.recordDirectoryChange(directory)
            }
        }

        func processTerminated(source: TerminalView, exitCode: Int32?) {
            Task { @MainActor in
                self.panel.recordExit(code: exitCode ?? -1)
            }
        }
    }
}

// MARK: - Process CWD helper

/// Read the current working directory of a process using proc_pidinfo.
func getProcessCWD(pid: pid_t) -> String? {
    var pathInfo = proc_vnodepathinfo()
    let size = MemoryLayout<proc_vnodepathinfo>.size
    let result = proc_pidinfo(pid, PROC_PIDVNODEPATHINFO, 0, &pathInfo, Int32(size))
    guard result == size else { return nil }
    return withUnsafePointer(to: pathInfo.pvi_cdir.vip_path) { ptr in
        ptr.withMemoryRebound(to: CChar.self, capacity: Int(MAXPATHLEN)) { cPath in
            String(cString: cPath)
        }
    }
}

// MARK: - Custom Terminal View

final class SmuxTerminalView: LocalProcessTerminalView {
    weak var panel: TerminalPanel?

    /// Extract scrollback text from the terminal buffer (for session persistence).
    func getScrollbackText(maxChars: Int = 400_000) -> String? {
        let terminal = getTerminal()

        // getText clamps out-of-range rows, so use a large end row to get everything.
        let start = Position(col: 0, row: 0)
        let end = Position(col: terminal.cols, row: 1_000_000)
        var text = terminal.getText(start: start, end: end)

        // Trim trailing whitespace/newlines
        while text.hasSuffix("\n") || text.hasSuffix(" ") {
            text = String(text.dropLast())
        }

        guard !text.isEmpty else { return nil }

        // Truncate from the front if too long, keeping whole lines
        if text.count > maxChars {
            text = String(text.suffix(maxChars))
            if let firstNewline = text.firstIndex(of: "\n") {
                text = String(text[text.index(after: firstNewline)...])
            }
        }

        return text
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        configureOverlayScroller()
    }

    /// Hide the scroller — terminal scrollback is handled via trackpad/keyboard.
    private func configureOverlayScroller() {
        for subview in subviews {
            if let scroller = subview as? NSScroller {
                scroller.isHidden = true
                break
            }
        }
    }

    override func dataReceived(slice: ArraySlice<UInt8>) {
        super.dataReceived(slice: slice)
        Task { @MainActor [weak self] in
            self?.panel?.recordOutput()
        }
    }

    override func bell(source: Terminal) {
        super.bell(source: source)
    }
}
