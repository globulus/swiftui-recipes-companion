//
//  HomeViewModel.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    private let recipeRepo: RecipeRepo
    private var userDefaultsManager: UserDefaultsManager
    
    private var subs = Set<AnyCancellable>()
    
    @Published var isLoading = false
    @Published var loadingMessage = ""
    @Published var recipes = [Recipe]()
    @Published var focusRecipe: Recipe? = nil
    @Published var saveMessage = ""
    @Published var errorMessage = ""
    
    init(recipeRepo: RecipeRepo,
         userDefaultsManager: UserDefaultsManager) {
        self.recipeRepo = recipeRepo
        self.userDefaultsManager = userDefaultsManager
    }
    
    func loadRecipes() {
        isLoading = true
        let pub = recipeRepo.getRecipes()
        pub.progress?
            .sink(receiveValue: { [self] progress in
                switch progress {
                case .listing:
                    loadingMessage = "Listing available recipes..."
                case .fetching(index: let index, total: let total):
                    loadingMessage = "Fetching recipe \(index) of \(total)"
                }
            })
            .store(in: &subs)
        pub.result
            .sinkJust { [self] response in
                focusRecipe = nil
                recipes = response
                saveMessage = "Please review the recipe list, exclude those you don't need in your Editor Extension, and then press 'Save'."
            } onError: { [self] error in
                errorMessage = error.localizedDescription
            } onDone: { [self] in
                isLoading = false
            }
            .store(in: &subs)
    }
    
    func toggleIsActive(for recipe: Recipe) {
        if let index = recipes.firstIndex(of: recipe) {
            var mutableRecipe = recipe
            mutableRecipe.header.isActive = (recipe.header.isActive == nil) ? false : !recipe.header.isActive!
            recipes[index] = mutableRecipe
        }
    }
    
    func saveRecipes() {
        userDefaultsManager.recipes = recipes
        saveMessage = "Recipes saved successfully! You can now use the Editor Extension!"
    }
}
