//
//  SourceEditorExtension.swift
//  Helper
//
//  Created by Gordan Glavaš on 27.07.2021..
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    func extensionDidFinishLaunching() {
        
    }
    
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        recipeManager.recipes
            .filter { $0.header.isActive != false }
            .map { recipe in
                [.classNameKey: SourceEditorCommand.className(),
                 .identifierKey: recipe.commandIdentifier,
                 .nameKey: recipe.header.title
                ] as [XCSourceEditorCommandDefinitionKey: Any]
            }
        +  [[.classNameKey: SourceEditorCommand.className(),
            .identifierKey: SourceEditorCommand.runCompanionCommandIdentifier,
            .nameKey: "Run Companion"
           ] as [XCSourceEditorCommandDefinitionKey: Any]]
    }
    
}
