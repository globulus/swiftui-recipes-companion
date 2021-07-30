//
//  RecipeManager.swift
//  Helper
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation

let recipeManager = RecipeManager()

class RecipeManager {
    let userDefaultsManager = UserDefaultsManagerImpl()
    
    fileprivate init() { }
    
    var recipes: [Recipe] {
        userDefaultsManager.recipes
    }
}

extension Recipe {
    var commandIdentifier: String {
        SourceEditorCommand.runCompanionCommandIdentifier + header.title
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
    }
}
