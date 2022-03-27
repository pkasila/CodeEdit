//
//  ExtensionWorkspaceConnector.swift
//  
//
//  Created by Pavel Kasila on 27.03.22.
//

import Foundation
import CEExtensionKit

typealias InitFunction = @convention(c) () -> UnsafeMutableRawPointer

enum ExtensionManagerError: Error {
    case symbolNotFound(symbol: String, path: String)
    case failedOpeningDylib(error: String?, path: String)
}

class ExtensionWorkspaceConnector {

    private(set) var plugins: [ExtensionManifest: ExtensionInterface] = [:]
    private(set) var workspace: WorkspaceDocument

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    func loadPlugin(from url: URL) throws {
        let manifestURL = url.appendingPathComponent("manifest.json")
        let manifest = try JSONDecoder().decode(ExtensionManifest.self,
                                                from: Data(contentsOf: manifestURL))

        let plugin = try self.plugin(at: url.appendingPathComponent("plugin.dylib").path,
                                     extensionId: manifest.id)
        plugins[manifest] = plugin
    }

    private func plugin(at path: String, extensionId: String) throws -> ExtensionInterface {
        let openRes = dlopen(path, RTLD_NOW|RTLD_LOCAL)
        if openRes != nil {
            defer {
                dlclose(openRes)
            }

            let symbolName = "createExtension"
            let sym = dlsym(openRes, symbolName)

            if sym != nil {
                let function: InitFunction = unsafeBitCast(sym, to: InitFunction.self)
                let pluginPointer = function()
                let builder = Unmanaged<ExtensionBuilder>.fromOpaque(pluginPointer).takeRetainedValue()

                let api = CodeEditAPI(extensionId: extensionId, workspace: workspace)

                return builder.build(withAPI: api)
            } else {
                throw ExtensionManagerError.symbolNotFound(symbol: symbolName, path: path)
            }
        } else {
            if let err = dlerror() {
                throw ExtensionManagerError.failedOpeningDylib(error: String(format: "%s", err), path: path)
            } else {
                throw ExtensionManagerError.failedOpeningDylib(error: nil, path: path)
            }
        }
    }
}
