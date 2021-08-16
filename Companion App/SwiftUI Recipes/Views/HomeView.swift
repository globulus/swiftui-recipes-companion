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
                    alternativeVersions
                    Divider()
                    HStack(alignment: .top) {
                        if header.image != nil {
                            recipeImage(viewModel.recipeImageData)
                        }
                        recipeCode
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background((colorScheme == .dark) ? Color.black : Color.white)
    }
    
    private var alternativeVersions: some View {
        Group {
            if !viewModel.alternativeVersionRecipes.isEmpty {
                Divider()
                Text("This recipe has alternative versions:")
                ForEach(viewModel.alternativeVersionRecipes, id: \.self) { variant in
                    Button(action: {
                        viewModel.focus(variant)
                    }) {
                        HStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 6, height: 6)
                            Text("Version for SwiftUI \(variant.header.versionRange)")
                        }
                        .padding(.leading, 8)
                        .foregroundColor(.blue)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func recipeImage(_ data: Data?) -> some View {
        ZStack {
            if let imageData = data {
                if viewModel.isRecipeImageGif,
                   let nsImage = try? NSImage(gifData: imageData) {
                    GIFImage(nsImage: nsImage)
                } else if let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300, maxHeight: 400)
                }
            } else {
                ActivityIndicator()
                    .onAppear(perform: viewModel.loadRecipeImage)
            }
        }
    }
    
    private var recipeCode: some View {
        VStack(alignment: .leading) {
            Button("Copy code to clipboard") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(viewModel.focusRecipe?.code ?? "", forType: .string)
            }
            WebView(action: $viewModel.webViewAction,
                    state: $viewModel.webViewState)
                .frame(minHeight: 400)
        }
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
