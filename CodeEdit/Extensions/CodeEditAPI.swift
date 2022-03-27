//
//  CodeEditAPI.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 27.03.22.
//

import Foundation
import CEExtensionKit

class CodeEditAPI: ExtensionAPI {
    var extensionId: String
    var workspace: WorkspaceDocument

    var workspaceURL: URL {
        return workspace.fileURL!
    }

    init(extensionId: String, workspace: WorkspaceDocument) {
        self.extensionId = extensionId
        self.workspace = workspace
    }

    lazy var targets: TargetsAPI = CodeEditTargetsAPI(workspace)
}
