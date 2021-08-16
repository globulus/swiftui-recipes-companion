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
import SwiftUIWebView
import HTMLEntities
import SwiftyGif

class HomeViewModel: ObservableObject {
    private let recipeRepo: RecipeRepo
    private var userDefaultsManager: UserDefaultsManager
    
    private var subs = Set<AnyCancellable>()
    private var allRecipes = [Recipe]()
    
    @Published var isLoading = false
    @Published var loadingMessage = ""
    
    @Published var filterText = ""
    @Published var advancedFilter = false
    @Published var minSwiftUIVersion: Float = 1.0
    @Published var maxSwiftUIVersion: Float = 3.0
    
    @Published var focusRecipe: Recipe?
    @Published var alternativeVersionRecipes = [Recipe]()
    @Published var recipeImageData: Data?
    @Published var webViewAction = WebViewAction.idle
    @Published var webViewState = WebViewState.empty
    
    @Published var saveMessage = ""
    @Published var errorMessage = ""
    
    var recipes: [Recipe] {
        let satisfiesSearch: (Recipe) -> Bool = filterText.isEmpty
            ? { _ in true }
            : { $0.header.title.localizedCaseInsensitiveContains(self.filterText)
                || $0.header.description.localizedCaseInsensitiveContains(self.filterText) }
        let satisfiesVersion: (Recipe) -> Bool = advancedFilter
            ? { $0.header.minSwiftUIVersion <= self.minSwiftUIVersion
                && ($0.header.maxSwiftUIVersion ?? Float.greatestFiniteMagnitude) >= self.maxSwiftUIVersion }
            : { _ in true }
        return allRecipes.filter { satisfiesSearch($0) && satisfiesVersion($0) }
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
            focusRecipe = focusRecipe // doing this to trigger an update
        }
    }
    
    func saveRecipes() {
        userDefaultsManager.recipes = recipes
        saveMessage = "Recipes saved successfully! You can now use the Editor Extension!"
    }
    
    func focus(_ recipe: Recipe) {
        recipeImageData = nil
        alternativeVersionRecipes = variants(for: recipe)
        focusRecipe = recipe
        loadRecipeCode()
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
                recipeImageData = data
            } onError: { [self] error in
                errorMessage = error.localizedDescription
            }
            .store(in: &subs)
    }
    
    var isRecipeImageGif: Bool {
        focusRecipe?.header.image?.hasSuffix("gif") == true
    }
    
    func loadRecipeCode() {
        guard let recipe = focusRecipe,
              let path = Bundle.main.path(forResource: "HighlightTemplate", ofType: "html"),
              let data = FileManager.default.contents(atPath: path),
              let content = String(data: data, encoding: .utf8)
        else {
            return
        }
        let fullCode = content.replacingOccurrences(of: "RECIPE_CODE", with: recipe.code.htmlEscape())
        webViewAction = .loadHTML(fullCode)
    }
    
    private func variants(for recipe: Recipe) -> [Recipe] {
        guard let fileName = recipe.fileName,
              let atIndex = fileName.firstIndex(of: "@")
        else {
            return []
        }
        let commonName = fileName[..<atIndex]
        return recipes.filter { $0 != recipe && $0.fileName?.contains(commonName) == true }
    }
}
