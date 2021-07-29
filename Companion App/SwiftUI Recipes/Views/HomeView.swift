//
//  HomeView.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private(set) var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            headerView
                .padding(.bottom, 15)
            recipeList
            saveView
            detailsView
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear(perform: viewModel.loadRecipes)
    }
    
    private var headerView: some View {
        HStack {
            Text("Available recipes: (click any to see details)")
            Spacer()
            refreshView
        }
    }
    
    private var refreshView: some View {
        Group {
            if viewModel.isLoading {
                ActivityIndicator()
                Text(viewModel.loadingMessage)
            } else {
                Button("Refresh") {
                    viewModel.loadRecipes()
                }
            }
        }
    }
    
    private var recipeList: some View {
        GeometryReader { geo in
            VStack {
                listViewHeader(geo)
                recipeListView(geo)
            }
        }
    }
    
    private func listViewHeader(_ geo: GeometryProxy) -> some View {
        HStack {
            Text("Title")
                .frame(width: geo.size.width * 0.4)
            Text("Updated at")
                .frame(width: geo.size.width * 0.25)
            Text("SwiftUI Version")
                .frame(width: geo.size.width * 0.15)
            Text("Include")
                .frame(width: geo.size.width * 0.2)
        }
    }
    
    private func recipeListView(_ geo: GeometryProxy) -> some View {
        List(viewModel.recipes, id: \.self) { recipe in
            Button(action: {
                viewModel.focusRecipe = recipe
            }) {
                HStack {
                    Text(recipe.header.title)
                        .frame(width: geo.size.width * 0.4, alignment: .leading)
                    Text(recipe.header.formattedUpdatedAt)
                        .frame(width: geo.size.width * 0.25, alignment: .leading)
                    Text(recipe.header.versionRange)
                        .frame(width: geo.size.width * 0.15, alignment: .leading)
                    Button(action: {
                        viewModel.toggleIsActive(for: recipe)
                    }) {
                        Text((recipe.header.isActive == false) ? "Excluded" : "Included")
                    }
                    .frame(width: geo.size.width * 0.2, alignment: .leading)
                }
            }
        }
    }
    
    private var saveView: some View {
        HStack {
            Text(viewModel.saveMessage)
            Spacer()
            Button("Save", action: viewModel.saveRecipes)
        }
    }
    
    private var detailsView: some View {
        ScrollView {
            HStack(alignment: .top) {
                if let header = viewModel.focusRecipe?.header {
                    VStack(alignment: .leading) {
                        Text("Title: \(header.title)")
                        Text("Description: \(header.description)")
                        Text("Author: \(header.author)")
                        Button("URL: \(header.url)") {
                            if let url = URL(string: header.url) {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        Text("Updated at: \(header.formattedUpdatedAt)")
                        Text("SwiftUI Version: \(header.versionRange)")
                    }
                }
                Text(viewModel.focusRecipe?.code ?? "")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .background(Color.white)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: inject())
    }
}
