//
//  ActivityIndicator.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import Foundation
import SwiftUI

public struct ActivityIndicator: NSViewRepresentable {
    public typealias NSViewType = NSProgressIndicator
    
    public func makeNSView(context: Context) -> NSProgressIndicator {
        let view = NSViewType()
        view.style = .spinning
        view.startAnimation(nil)
        return view
    }
    
    public func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
    }
}
