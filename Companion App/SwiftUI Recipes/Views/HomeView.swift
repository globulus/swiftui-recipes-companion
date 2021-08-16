//
//  HomeView.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import SwiftUI
import SwiftUIWebView

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private(set) var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    headerView
                    recipeList
                    SearchBar(isShowing: .constant(true), text: $viewModel.filterText)
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
            Text("Available recipes (\(viewModel.recipes.count)):")
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
                Button(action: {
                    viewModel.toggleIsActive(for: recipe)
                }) {
                    Group {
                        if #available(macOS 11, *) {
                            Group {
                                if recipe.header.isActive == false {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.red)
                                } else {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .imageScale(.large)
                        } else {
                            Text((recipe.header.isActive == false) ? "❌" : "✓")
                                .font(.system(size: 24))
                        }
                    }
                    .frame(width: 30)
                }
                Button(action: {
                    viewModel.focus(recipe)
                }) {
                    HStack {
                        Text(recipe.header.title)
                            .lineLimit(nil)
                        Spacer()
                        Group {
                            if #available(macOS 11, *) {
                                Image(systemName: "chevron.right")
                                    .imageScale(.large)
                            } else {
                                Text("›")
                                    .font(.system(size: 32))
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .background((colorScheme == .dark) ? Color.black : Color.white)
        .buttonStyle(PlainButtonStyle())
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
            VStack(alignment: .leading, spacing: 8) {
                if let header = viewModel.focusRecipe?.header {
                    Text(header.title)
                        .font(.largeTitle)
                    Text(header.description)
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
                    Divider()
                    HStack(alignment: .top) {
                        if header.image != nil {
                            if let image = viewModel.recipeImage {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 300, maxHeight: 400)
                            } else {
                                ActivityIndicator()
                                    .onAppear(perform: viewModel.loadRecipeImage)
                            }
                        }
                        VStack(alignment: .leading) {
                            Button("Copy code to clipboard") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(viewModel.focusRecipe!.code, forType: .string)
                            }
                            WebView(action: $viewModel.webViewAction,
                                    state: $viewModel.webViewState)
                                .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(Color.red))
                                .frame(minHeight: 400)
                            }
                        }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background((colorScheme == .dark) ? Color.black : Color.white)
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
