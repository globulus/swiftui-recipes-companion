//
//  RecipeFileList.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation

struct RecipeMetadata: Codable {
    let minSwiftUIVersion: Int?
    let maxSwiftUIVersion: Int?
}

struct RecipeFileList: Codable {
    let recipes: [[String: RecipeMetadata]]
}
