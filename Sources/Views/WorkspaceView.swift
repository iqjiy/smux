import SwiftUI

struct WorkspaceView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var workspace: Workspace

    var body: some View {
        ZStack {
            themeManager.colors.workspaceBackground.ignoresSafeArea()

            if workspace.isZoomed, let focusedID = workspace.focusedPanelID,
               let panel = workspace.panels[focusedID] {
                PaneView(panel: panel, workspace: workspace, nodeID: UUID())
                    .padding(4)
            } else {
                SplitNodeView(node: workspace.rootNode, workspace: workspace)
                    .padding(4)
            }
        }
    }
}
