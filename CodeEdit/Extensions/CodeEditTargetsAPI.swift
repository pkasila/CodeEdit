//
//  CodeEditTargetsAPI.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 27.03.22.
//

import Foundation
import CEExtensionKit

class CodeEditTargetsAPI: TargetsAPI {

    var workspace: WorkspaceDocument

    init(_ workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    func add(target: Target) {
        self.workspace.target(didAdd: target)
    }

    func delete(target: Target) {
        self.workspace.target(didRemove: target)
    }

    func clear() {
        self.workspace.targetDidClear()
    }
}
