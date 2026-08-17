import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var workspaceManager: WorkspaceManager

    var body: some View {
        List {
            Section("Workspaces") {
                ForEach(workspaceManager.workspaces) { workspace in
                    WorkspaceRow(workspace: workspace,
                                 isSelected: workspace.id == workspaceManager.selectedWorkspaceID)
                        .listRowBackground(Color.clear)
                        .onTapGesture {
                            workspaceManager.selectedWorkspaceID = workspace.id
                        }
                        .contextMenu {
                            Button("Rename") {
                                workspace.isRenaming = true
                            }
                            Divider()
                            Button("Close Workspace", role: .destructive) {
                                workspaceManager.deleteWorkspace(id: workspace.id)
                            }
                            .disabled(workspaceManager.workspaces.count <= 1)
                        }
                }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .frame(minWidth: 180)
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                let ws = workspaceManager.createWorkspace()
                workspaceManager.selectedWorkspaceID = ws.id
            }) {
                Label("New Workspace", systemImage: "plus")
            }
            .buttonStyle(.borderless)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .help("New Workspace (⇧⌘T)")
        }
    }
}

struct WorkspaceRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var workspace: Workspace
    var isSelected: Bool = false
    @State private var isHovered: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            if workspace.isRenaming {
                RenameField(text: $workspace.name) {
                    workspace.isRenaming = false
                }
                .font(.system(size: 13))
                .frame(maxWidth: 140)
            } else {
                Text(workspace.name)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .foregroundStyle(isSelected ? .primary : isHovered ? .primary : .secondary)
            }

            Spacer()

            let summary = workspace.activitySummary

            if summary.attention > 0 {
                BadgeView(count: summary.attention, color: .orange)
            } else if summary.active > 0 {
                BadgeView(count: summary.active, color: .green)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    isSelected ? themeManager.colors.sidebarSelectedBg : isHovered ? themeManager.colors.sidebarHoveredBg : Color.clear
                )
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct BadgeView: View {
    let count: Int
    let color: Color

    var body: some View {
        Text("\(count)")
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(Capsule().fill(color))
    }
}
