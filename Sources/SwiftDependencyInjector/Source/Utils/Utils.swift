//
//  Utils.swift
//  
//
//  Created by Andres Duque on 6/07/23.
//

import Foundation

/// Common utilities.
struct Utils {

    /// To extract name as string from generic object.
    /// - Parameter object: Any object.
    /// - Returns: A representation of object name.
    static func createName<Object>(
        for object: Object.Type
    ) -> String {
        String(describing: Object.self)
    }

    /// To extract just the file name from a full path.
    /// - Parameters:
    ///   - filePath: The original file path.
    ///   - withExtension: To define the obtained string will contains the file extension.
    /// - Returns: A string representing the name of the file.
    static func extractFileName(
        of filePath: String,
        withExtension: Bool
    ) -> String {
        let fileName = (filePath as NSString).lastPathComponent

        return withExtension
            ? fileName
            : (fileName as NSString).deletingPathExtension
    }
}
