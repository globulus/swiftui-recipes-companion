//
//  Environment.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation

private let dev = EnvironmentConfig(branch: "develop")
private let prod = EnvironmentConfig(branch: "main")

let environment = dev
#if DEBUG
var isDebug = true
#else
var isDebug = false
#endif

struct EnvironmentConfig {
    let branch: String
    
    var baseUrl: String {
        "https://raw.githubusercontent.com/globulus/swiftui-recipes-companion/\(branch)/"
    }
}
