//
//  Logging.swift
//  SwiftUI Recipes
//
//  Created by Gordan Glavaš on 28.07.2021..
//

import SwiftyBeaver
import Combine

let log = SwiftyBeaver.self

private let MAX_DIAGNOSTICS_SIZE: UInt64 = 10 * 1024 * 1024 // 10 MB

class Logging {
//    private var fileURL: URL!
    private let networking: Networking
    
    init(networking: Networking) {
        self.networking = networking
    }
    
    func setUp() {
        let format = "$Ddd-MM-yyyy HH:mm:ss.SSS$d $C$L$c $T $N.$F:$l - $M"
        
        let console = ConsoleDestination()
        console.format = format
        log.addDestination(console)
        
//        fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("SwiftUIRecipes.log")
//        if let size = FileUtil.sizeOfFile(at: fileURL),
//           size > MAX_DIAGNOSTICS_SIZE {
//            FileUtil.deleteFile(at: fileURL)
//        }
//
//        let file = FileDestination()
//        file.logFileURL = fileURL
//        file.format = format
//        file.asynchronously = !isDebug
//        file.minLevel = .debug
//        log.addDestination(file)
    }
}
