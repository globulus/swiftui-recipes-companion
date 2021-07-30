//
//  WebView.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 30.07.2021..
//

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    typealias NSViewType = WKWebView
    
    let content: String
    
    func makeNSView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = false
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(content: "<html><body><b>Text</b></body></html>")
    }
}
