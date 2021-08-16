//
//  GIFImage.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 16.08.2021..
//

import SwiftUI
import SwiftyGif

struct GIFImage: NSViewRepresentable {
    let nsImage: NSImage
    
    func makeNSView(context: Context) -> NSImageView {
        let view = NSImageView(gifImage: nsImage, loopCount: -1)
        view.imageScaling = .scaleProportionallyDown
        return view
    }
    
    func updateNSView(_ nsView: NSImageView, context: Context) {
        nsView.gifImage = nsImage
    }
}
