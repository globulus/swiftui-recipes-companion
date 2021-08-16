//
//  Recipe.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation

struct RecipeHeader: Codable, Hashable {
    let title: String
    let description: String
    let author: String
    let url: String?
    let image: String?
    let updatedAt: String
    let minSwiftUIVersion: Float
    let maxSwiftUIVersion: Float?
    
    var isActive: Bool?
}

struct Recipe: Codable, Hashable {
    var header: RecipeHeader
    let code: String
    
    var fileName: String?
}

