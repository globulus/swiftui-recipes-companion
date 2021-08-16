//
//  SearchBar.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 03.08.2021..
//

import SwiftUI

struct SearchBar: View {
    @Binding var isShowing: Bool // determines visibility
    @Binding var text: String // the inputted search text

    var body: some View {
        Group {
            // If the bar should be shown, render it, otherwise
            // use an EmptyView
            if isShowing {
                HStack {
                    searchText
                    cancelButton
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var searchText: some View {
        TextField("Search...", text: $text)
            .padding(7)
            .padding(.leading, 30)
            .cornerRadius(8)
            .overlay(HStack { // Add the search icon to the left
                Group {
                    if #available(macOS 11, *) {
                         Image(systemName: "magnifyingglass")
                            .frame(width: 24, height: 24)
                    } else {
                        Image("magnifying-glass")
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.leading, 8)
                Spacer()
            }).padding(.horizontal, 10)
    }
    
    private var cancelButton: some View {
        Group {
            // If the search field is focused, render the "Cancel" button
            // to the right that hides the search bar altogether
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                    self.isShowing = false
                }) {
                    Text("Clear")
                        .foregroundColor(.white)
                }.padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}
