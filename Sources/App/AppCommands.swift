import SwiftUI

struct AppCommands: Commands {
    @ObservedObject var workspaceManager: WorkspaceManager
    @ObservedObject var themeManager: ThemeManager

    var body: some Commands {
        // MARK: - File Menu

        CommandGroup(after: .newItem) {
            Button("New Workspace") {
                let ws = workspaceManager.createWorkspace()
                workspaceManager.selectedWorkspaceID = ws.id
            }
            .keyboardShortcut("t", modifiers: [.command, .shift])
        }

        // MARK: - View Menu (Theme)

        CommandGroup(after: .toolbar) {
            Button("Toggle Light/Dark Theme") {
                themeManager.toggle()
            }
            .keyboardShortcut("l", modifiers: [.command, .shift])
        }

        // MARK: - Pane Menu

        CommandMenu("Terminal") {
            Button("Close Terminal") {
                selectedWorkspace?.closeFocusedPane()
            }
            .keyboardShortcut("w", modifiers: [.command])

            Divider()

            // Split: ⌘+Arrow
            Button("Split Right") {
                selectedWorkspace?.splitFocusedPane(direction: .horizontal)
            }
            .keyboardShortcut(.rightArrow, modifiers: [.command])

            Button("Split Down") {
                selectedWorkspace?.splitFocusedPane(direction: .vertical)
            }
            .keyboardShortcut(.downArrow, modifiers: [.command])

            Divider()

            Button("Zoom Terminal") {
                selectedWorkspace?.toggleZoom()
            }
            .keyboardShortcut(.return, modifiers: [.command, .shift])

            Divider()

            // Navigate: ⌥+Arrow
            Button("Jump Left") {
                selectedWorkspace?.focusAdjacentPane(direction: .left)
            }
            .keyboardShortcut(.leftArrow, modifiers: [.option])

            Button("Jump Right") {
                selectedWorkspace?.focusAdjacentPane(direction: .right)
            }
            .keyboardShortcut(.rightArrow, modifiers: [.option])

            Button("Jump Up") {
                selectedWorkspace?.focusAdjacentPane(direction: .up)
            }
            .keyboardShortcut(.upArrow, modifiers: [.option])

            Button("Jump Down") {
                selectedWorkspace?.focusAdjacentPane(direction: .down)
            }
            .keyboardShortcut(.downArrow, modifiers: [.option])

            Divider()

            // Notification toggle: ⌘B (bell)
            Button("Toggle Notifications") {
                guard let ws = selectedWorkspace,
                      let id = ws.focusedPanelID,
                      let panel = ws.panels[id] else { return }
                panel.watchMode = panel.watchMode.next
            }
            .keyboardShortcut("b", modifiers: [.command])
        }

        // MARK: - Workspace Navigation

        CommandMenu("Workspace") {
            ForEach(Array(workspaceManager.workspaces.enumerated().prefix(9)), id: \.element.id) { index, workspace in
                Button(workspace.name) {
                    workspaceManager.selectedWorkspaceID = workspace.id
                }
                .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: [.command])
            }

            Divider()

            // Cycle workspaces: ⌥⇧+Arrow
            Button("Next Workspace") {
                workspaceManager.selectNextWorkspace()
            }
            .keyboardShortcut(.rightArrow, modifiers: [.option, .shift])

            Button("Previous Workspace") {
                workspaceManager.selectPreviousWorkspace()
            }
            .keyboardShortcut(.leftArrow, modifiers: [.option, .shift])

            Button("Next Workspace (Down)") {
                workspaceManager.selectNextWorkspace()
            }
            .keyboardShortcut(.downArrow, modifiers: [.option, .shift])

            Button("Previous Workspace (Up)") {
                workspaceManager.selectPreviousWorkspace()
            }
            .keyboardShortcut(.upArrow, modifiers: [.option, .shift])
        }

        // MARK: - Help / Shortcuts

        CommandGroup(replacing: .help) {
            Button(action: { showShortcutsWindow() }) {
                Label("Keyboard Shortcuts", systemImage: "keyboard")
            }
            .keyboardShortcut("/", modifiers: [.command])
        }
    }

    private var selectedWorkspace: Workspace? {
        workspaceManager.selectedWorkspace
    }

    private func showShortcutsWindow() {
        let id = "smux-shortcuts"
        // Reuse existing window if open
        if let existing = NSApp.windows.first(where: { $0.identifier?.rawValue == id }) {
            existing.makeKeyAndOrderFront(nil)
            return
        }
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 460),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        panel.identifier = NSUserInterfaceItemIdentifier(id)
        panel.title = "Keyboard Shortcuts"
        panel.isFloatingPanel = true
        panel.contentView = NSHostingView(rootView: ShortcutsCheatSheet())
        panel.center()
        panel.makeKeyAndOrderFront(nil)
    }
}

private struct ShortcutsCheatSheet: View {
    private let sections: [(String, [(String, String)])] = [
        ("Terminal", [
            ("Close Terminal", "⌘W"),
            ("Split Right", "⌘→"),
            ("Split Down", "⌘↓"),
            ("Zoom Terminal", "⇧⌘↩"),
            ("Toggle Notifications", "⌘B"),
            ("Jump Left", "⌥←"),
            ("Jump Right", "⌥→"),
            ("Jump Up", "⌥↑"),
            ("Jump Down", "⌥↓"),
        ]),
        ("Workspace", [
            ("New Workspace", "⇧⌘T"),
            ("Jump Next", "⌥⇧→  or  ⌥⇧↓"),
            ("Jump Previous", "⌥⇧←  or  ⌥⇧↑"),
        ]),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(sections, id: \.0) { section in
                VStack(alignment: .leading, spacing: 6) {
                    Text(section.0)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)

                    ForEach(section.1, id: \.0) { item in
                        HStack {
                            Text(item.0)
                                .font(.system(size: 13))
                            Spacer()
                            Text(item.1)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if section.0 != sections.last?.0 {
                    Divider()
                }
            }
        }
        .padding(24)
        .frame(width: 400)
    }
}
