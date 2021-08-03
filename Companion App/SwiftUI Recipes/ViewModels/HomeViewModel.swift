//
//  HomeViewModel.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation
import SwiftUI
import Combine
import Alamofire

class HomeViewModel: ObservableObject {
    private let recipeRepo: RecipeRepo
    private var userDefaultsManager: UserDefaultsManager
    
    private var subs = Set<AnyCancellable>()
    private var allRecipes = [Recipe]()
    
    @Published var isLoading = false
    @Published var loadingMessage = ""
    @Published var filterText = ""
    @Published var focusRecipe: Recipe? = nil
    @Published var recipeImage: NSImage? = nil
    @Published var saveMessage = ""
    @Published var errorMessage = ""
    
    var recipes: [Recipe] {
        filterText.isEmpty
            ? allRecipes
            : allRecipes.filter { $0.header.title.localizedCaseInsensitiveContains(filterText)
                || $0.header.description.localizedCaseInsensitiveContains(filterText) }
    }
    
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
                allRecipes = response.sorted(by: { $0.header.title < $1.header.title })
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
            allRecipes[index] = mutableRecipe
        }
    }
    
    func saveRecipes() {
        userDefaultsManager.recipes = recipes
        saveMessage = "Recipes saved successfully! You can now use the Editor Extension!"
    }
    
    func focus(_ recipe: Recipe) {
        recipeImage = nil
        focusRecipe = recipe
    }
    
    func loadRecipeImage() {
        guard let recipe = focusRecipe,
              let url = recipe.header.image
        else {
            return
        }
        AF.request(url)
            .publishData()
            .tryMap { response -> Data in
                if let data = response.data {
                    return data
                } else {
                    throw NetworkingError.serverError(response.error?.localizedDescription ?? "")
                }
            }
            .sinkJust { [self] data in
                recipeImage = NSImage(data: data)
            } onError: { [self] error in
                errorMessage = error.localizedDescription
            }
            .store(in: &subs)
    }
    
    var codeHTMLWithHighlight: String? {
        guard let recipe = focusRecipe
//              let path = Bundle.main.path(forResource: "HighlightTemplate", ofType: "html"),
//              let data = FileManager.default.contents(atPath: path),
//              let content = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return recipe.code // content.replacingOccurrences(of: "RECIPE_CODE", with: recipe.code)
    }
}
