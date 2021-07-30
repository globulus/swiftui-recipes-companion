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
            NavigationView {
                VStack {
                    headerView
                    recipeList
                    saveView
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                    }
                }
                .frame(minWidth: 300)
                .onAppear(perform: viewModel.loadRecipes)
                
                detailsView
            }
            infoView
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Available recipes:")
            Spacer()
            refreshView
        }
        .padding()
    }
    
    private var refreshView: some View {
        Group {
            if viewModel.isLoading {
                ActivityIndicator()
                Text(viewModel.loadingMessage)
            } else {
                Button("Refresh", action: viewModel.loadRecipes)
            }
        }
    }
    
    private var recipeList: some View {
        List(viewModel.recipes, id: \.self) { recipe in
            HStack {
                Text((recipe.header.isActive == false) ? "❌" : "✓")
                    .font(.system(size: 24))
                    .frame(width: 30)
                    .onTapGesture {
                        viewModel.toggleIsActive(for: recipe)
                    }
                Text(recipe.header.title)
                    .lineLimit(nil)
                Spacer()
                Text("›")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            .onTapGesture {
                viewModel.focus(recipe)
            }
        }
        .background(Color.white)
    }
    
    private var saveView: some View {
        HStack {
            Text(viewModel.saveMessage)
            Spacer()
            Button("Save", action: viewModel.saveRecipes)
        }
        .padding()
    }
    
    private var detailsView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let header = viewModel.focusRecipe?.header {
                    Text("Title: \(header.title)")
                    Text("Description: \(header.description)")
                    Text("Author: \(header.author)")
                    if let headerURL = header.url {
                        Button(headerURL) {
                            if let url = URL(string: headerURL) {
                                NSWorkspace.shared.open(url)
                            }
                        }
                    }
                    Text("Updated at: \(header.formattedUpdatedAt)")
                    Text("SwiftUI Version: \(header.versionRange)")
                    if header.image != nil {
                        Divider()
                        if let image = viewModel.recipeImage {
                            Image(nsImage: image)
                        } else {
                            ActivityIndicator()
                                .onAppear(perform: viewModel.loadRecipeImage)
                        }
                    }
                    Divider()
                    Button("Copy code to clipboard") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(viewModel.focusRecipe!.code, forType: .string)
                    }
                }
                Text(viewModel.codeHTMLWithHighlight ?? "")
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(Color.white)
    }
    
    private var infoView: some View {
        HStack {
            Image("info")
                .resizable()
                .frame(width: 15, height: 15)
            Text("The app and XCode extension are a part of the SwiftUI Recipes Companion project.")
            Button("Learn more & contribute!") {
                if let url = URL(string: "https://github.com/globulus/swiftui-recipes-companion") {
                    NSWorkspace.shared.open(url)
                }
            }
            Spacer()
        }
        .padding(5)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: inject())
    }
}
