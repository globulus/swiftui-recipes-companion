//
//  AppDelegate.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 27.07.2021..
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initDI()
        initLogging()
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 1200),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = true
        window.center()
        window.setFrameAutosaveName("SwiftUI Recipes Companion")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    // MARK: - Private methods
    
    private func initLogging() {
        let logging: Logging = inject()
        logging.setUp()
    }
}

