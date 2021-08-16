//
//  RecipeService.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation
import Combine
import Yams

protocol RecipeService {
    func getRecipes() -> ProgressPublisher<GetRecipesProgress, [Recipe]>
}

enum GetRecipesProgress {
    case listing,
         fetching(index: Int, total: Int)
}

class RecipeServiceImpl: RecipeService {
    private let networking: Networking
    
    init(networking: Networking) {
        self.networking = networking
    }
    
    func getRecipes() -> ProgressPublisher<GetRecipesProgress, [Recipe]> {
        let progressSubject = PassthroughSubject<GetRecipesProgress, Never>()
        let resultPublisher: CallbackPublisher<[Recipe]> = networking
            .get("Recipes/Recipes\((environment.version < 2) ? "" : "V\(environment.version)").yml", params: [:])
            .handleEvents(receiveRequest: { _ in
                progressSubject.send(.listing)
            })
            .decode(type: RecipeFileList.self, decoder: YAMLDecoder())
            .map(\.recipes)
            .flatMap { [self] files in
                Publishers.MergeMany(files.enumerated().map { idx, metadata in
                    let fileName = metadata.keys.first ?? ""
                    return networking.get("Recipes/\(fileName).yml", params: [:])
                        .handleEvents(receiveRequest: { _ in
                            progressSubject.send(.fetching(index: idx + 1, total: files.count))
                        })
                        .map { data in
                            var recipe = try? Recipe(from: String(data: data, encoding: .utf8))
                            recipe?.fileName = fileName
                            return recipe
                        }
                        .compactMap { $0 }
                        .eraseToAnyPublisher()
                } as [AnyPublisher])
            }
            .collect()
            .eraseToAnyPublisher()
        return ProgressPublisher(progress: progressSubject.eraseToAnyPublisher(),
                                 result: resultPublisher)
    }
}
