import SwiftUI

private let attentionOrange = Color(red: 0.9, green: 0.55, blue: 0.1)
private let activeGreen = Color(red: 0.2, green: 0.55, blue: 0.3)
private let focusBlue = Color(red: 0.35, green: 0.55, blue: 0.95)

struct PaneView: View {
    @EnvironmentObject var workspaceManager: WorkspaceManager
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var panel: TerminalPanel
    @ObservedObject var workspace: Workspace
    let nodeID: UUID

    private var theme: ThemeColors { themeManager.colors }

    private var isFocused: Bool {
        workspace.focusedPanelID == panel.id
    }

    private var watchIcon: String {
        switch panel.watchMode {
        case .off: return "bell.slash"
        case .on: return "bell.fill"
        case .silent: return "bell"
        }
    }

    private var watchHelp: String {
        switch panel.watchMode {
        case .off: return "Notifications: off"
        case .on: return "Notifications: on"
        case .silent: return "Notifications: silent"
        }
    }

    private var borderColor: Color {
        if panel.needsAttention {
            return attentionOrange.opacity(0.5)
        }
        if isFocused {
            return focusBlue.opacity(0.5)
        }
        if case .active = panel.activityState {
            return activeGreen.opacity(0.5)
        }
        return theme.borderDim
    }

    private var borderWidth: CGFloat {
        if panel.needsAttention || isFocused { return 1.5 }
        return 1
    }

    var body: some View {
        VStack(spacing: 0) {
            // Minimal title bar
            HStack(spacing: 6) {
                if panel.isRenaming {
                    RenameField(text: $panel.title) {
                        panel.hasCustomTitle = !panel.title.trimmingCharacters(in: .whitespaces).isEmpty
                        panel.isRenaming = false
                    }
                    .font(.system(size: 11, weight: .medium))
                    .frame(maxWidth: 200)
                } else {
                    Text(panel.title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isFocused ? theme.titleFocused : theme.titleUnfocused)
                        .lineLimit(1)
                        .contextMenu {
                            Button("Rename") {
                                panel.isRenaming = true
                            }
                        }
                }

                Spacer()

                if case .exited(let code) = panel.activityState {
                    Text("exit \(code)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(code == 0 ? theme.exitCodeNormal : .red.opacity(0.8))
                }

                // Watch toggle + split/close buttons
                HStack(spacing: 0) {
                    PaneTitleButton(
                        systemName: watchIcon,
                        help: watchHelp
                    ) {
                        panel.watchMode = panel.watchMode.next
                    }

                    PaneTitleButton(systemName: "square.split.2x1", help: "Split Right (⌘→)") {
                        workspace.focusedPanelID = panel.id
                        workspace.splitFocusedPane(direction: .horizontal)
                    }
                    PaneTitleButton(systemName: "square.split.1x2", help: "Split Down (⌘↓)") {
                        workspace.focusedPanelID = panel.id
                        workspace.splitFocusedPane(direction: .vertical)
                    }
                    if workspace.rootNode.leafCount > 1 {
                        PaneTitleButton(systemName: "xmark", help: "Close (⌘W)") {
                            workspace.focusedPanelID = panel.id
                            workspace.closeFocusedPane()
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(panel.needsAttention ? attentionOrange.opacity(0.15) : theme.titlebarBackground)
            .onTapGesture {
                panel.clearAttention()
                workspace.focusedPanelID = panel.id
            }

            // Terminal
            TerminalSurfaceView(panel: panel, isFocused: isFocused, isWorkspaceSelected: workspace.id == workspaceManager.selectedWorkspaceID, suppressFocus: workspace.isRenaming)
                .padding(.horizontal, 8)
                .onTapGesture {
                    panel.clearAttention()
                    workspace.focusedPanelID = panel.id
                }
        }
        .background(theme.paneBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(borderColor, lineWidth: borderWidth)
        )
    }
}

struct PaneTitleButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    let systemName: String
    let help: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(themeManager.colors.buttonIcon)
                .frame(width: 20, height: 20)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help)
    }
}

struct RenameField: View {
    @Binding var text: String
    var onCommit: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("Name", text: $text)
            .textFieldStyle(.plain)
            .focused($isFocused)
            .onSubmit { onCommit() }
            .onExitCommand { onCommit() }
            .onAppear { isFocused = true }
            .onChange(of: isFocused) { _, focused in
                if !focused { onCommit() }
            }
    }
}
