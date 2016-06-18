//
//  LocalStorage.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 1/03/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

/// Functions to store support files on device
class LocalStorage {
    
    // Singleton
    static let sharedInstance = LocalStorage()
    
    func getAppSupportURL () -> URL {
        #if os(OSX)
            return NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent(getExecutableName())
        #elseif os(iOS)
            return FileManager.default().urlsForDirectory(.applicationSupportDirectory, inDomains: .userDomainMask)[0]
        #endif
    }
    
    func getExecutableName () -> String {
        return ProcessInfo.processInfo().processName
    }
    
}
