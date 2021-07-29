//
//  UserDefaultsManager.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation

protocol UserDefaultsManager {
    var recipes: [Recipe] { get set }
}

class UserDefaultsManagerImpl: UserDefaultsManager {
    private let sharedDefaults = UserDefaults(suiteName: "group.com.swiftuirecipes.helper")!
    private let recipesKey = "recipes"
    
    var recipes: [Recipe] {
        get {
            guard let json = sharedDefaults.string(forKey: recipesKey),
                  let data = json.data(using: .utf8),
                  let recipes = try? jsonDecoder.decode([Recipe].self, from: data)
            else {
                return []
            }
            return recipes
        }
        set {
            guard let data = try? jsonEncoder.encode(newValue),
                  let json = String(data: data, encoding: .utf8)
            else {
                return
            }
            sharedDefaults.set(json, forKey: recipesKey)
        }
    }
}
