//
//  SourceEditorCommand.swift
//  Helper
//
//  Created by Gordan Glavaš on 27.07.2021..
//

import Foundation
import XcodeKit
import AppKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    static let commandIdentifierPrefix = "com.swiftuirecipes.SwiftUI-Recipes.Helper.SourceEditorCommand."
    static let runCompanionCommandIdentifier = commandIdentifierPrefix + "RunCompanion"
    
    func perform(with invocation: XCSourceEditorCommandInvocation,
                 completionHandler: @escaping (Error?) -> Void ) -> Void {
        if invocation.commandIdentifier == SourceEditorCommand.runCompanionCommandIdentifier {
            let path = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            try? NSWorkspace.shared.launchApplication(at: path, options: .withoutActivation, configuration: [:])
        } else {
            // Retrieve the contents of the current source editor.
            let lines = invocation.buffer.lines
            let code = recipeManager.recipes.first(where: { $0.commandIdentifier == invocation.commandIdentifier })?.code ?? ""
            if let insertionIndex = (invocation.buffer.selections.firstObject as? XCSourceTextRange)?.end {
                lines.insert(code, at: insertionIndex.line)
            } else {
                lines.addObjects(from: [code])
            }
        }
        // Signal to Xcode that the command has completed.
        completionHandler(nil)
    }
    
}
