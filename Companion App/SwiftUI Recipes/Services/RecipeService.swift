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
            .get("Recipes/Recipes.yml", params: [:])
            .handleEvents(receiveRequest: { _ in
                progressSubject.send(.listing)
            })
            .decode(type: RecipeFileList.self, decoder: YAMLDecoder())
            .map(\.recipes)
            .flatMap { [self] files in
                Publishers.MergeMany(files.enumerated().map { idx, file in
                    networking.get("Recipes/\(file).yml", params: [:])
                        .handleEvents(receiveRequest: { _ in
                            progressSubject.send(.fetching(index: idx + 1, total: files.count))
                        })
                        .tryMap { data in
                            try Recipe(from: String(data: data, encoding: .utf8))
                        }
                        .eraseToAnyPublisher()
                })
            }
            .collect()
            .eraseToAnyPublisher()
        return ProgressPublisher(progress: progressSubject.eraseToAnyPublisher(),
                                 result: resultPublisher)
    }
}
