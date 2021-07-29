//
//  ContentView.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 27.07.2021..
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView(viewModel: inject())
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
