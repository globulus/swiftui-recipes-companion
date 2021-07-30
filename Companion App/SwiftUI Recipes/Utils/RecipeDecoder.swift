//
//  RecipeDecoder.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation
import Yams

extension Recipe {
    init(from source: String?) throws {
        let frontmatterLimit = "---"
        let frontmatterPattern = "(?s)(?<=\(frontmatterLimit)\n).*(?=\n\(frontmatterLimit))"
        guard let src = source,
              let headerRange = src.range(of: frontmatterPattern, options: .regularExpression)
        else {
            throw RecipeDecodingError.noHeader
        }
        let headerYAML = String(src[headerRange])
        do {
            header = try YAMLDecoder().decode(RecipeHeader.self, from: headerYAML)
        } catch {
            throw RecipeDecodingError.invalidHeaderFormat(error)
        }
        let codeIndex = src.index(headerRange.upperBound, offsetBy: frontmatterLimit.count + 1)
        code = String(src[codeIndex...])
    }
    
    enum RecipeDecodingError: Error {
        case noHeader,
             invalidHeaderFormat(Error)
    }
}
