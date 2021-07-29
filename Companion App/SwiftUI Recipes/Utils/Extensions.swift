//
//  Extensions.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 29.07.2021..
//

import Foundation

extension Float {
    var removingZeroDecimal: String {
        if trunc(self) == self {
            return "\(Int(self))"
        } else {
            return String(format: "%.1f", self)
        }
    }
}

extension RecipeHeader {
    var versionRange: String {
        var range = minSwiftUIVersion.removingZeroDecimal
        if let maxVersion = maxSwiftUIVersion {
            range += "-\(maxVersion.removingZeroDecimal)"
        }
        return range
    }
    
    var formattedUpdatedAt: String {
        updatedAt.replacingOccurrences(of: "T", with: " @ ")
    }
}
