//
//  RecipeRepo.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation

protocol RecipeRepo {
    func getRecipes() -> ProgressPublisher<GetRecipesProgress, [Recipe]>
}

class RecipeRepoImpl: RecipeRepo {
    private let service: RecipeService
    private let userDefaultsManager: UserDefaultsManager
    
    init(service: RecipeService,
         userDefaultsManager: UserDefaultsManager) {
        self.service = service
        self.userDefaultsManager = userDefaultsManager
    }
    
    func getRecipes() -> ProgressPublisher<GetRecipesProgress, [Recipe]> {
        let servicePub = service.getRecipes()
        return ProgressPublisher(progress: servicePub.progress,
                                 result: servicePub.result
                                    .map { [self] serverRecipes in
                                        let localRecipes = userDefaultsManager.recipes
                                        return serverRecipes.map { serverRecipe in
                                            if let localRecipe = localRecipes.first(where: { $0.header.title == serverRecipe.header.title }) {
                                                var mutableRecipe = serverRecipe
                                                mutableRecipe.header.isActive = localRecipe.header.isActive
                                                return mutableRecipe
                                            } else {
                                                return serverRecipe
                                            }
                                        }
                                    }
                                    .eraseToAnyPublisher())
    }
}
