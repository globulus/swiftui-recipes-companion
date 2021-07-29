//
//  DIGraph.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation

func initDI() {
    Dependencies {
        // MARK: - Utils
        Service(of: Networking.self, .singleton) { _ in NetworkingImpl() }
        Service(.singleton) { Logging(networking: $0.get()) }
        Service(of: UserDefaultsManager.self, .singleton) { _ in UserDefaultsManagerImpl() }
        
        // MARK: - Services
        Service(of: RecipeService.self, .singleton) { RecipeServiceImpl(networking: $0.get()) }
        
        // MARK: - Repos
        Service(of: RecipeRepo.self, .singleton) { RecipeRepoImpl(service: $0.get(), userDefaultsManager: $0.get()) }
        
        // MARK: - View Models
        Service { HomeViewModel(recipeRepo: $0.get(), userDefaultsManager: $0.get()) }
    }.build()
}

// Inject dependencies either with @Inject or inject()
// @Inject var rootViewModel: RootViewModel
// RootView(viewModel: inject())
