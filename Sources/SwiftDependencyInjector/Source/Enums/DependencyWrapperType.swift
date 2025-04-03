//
//  DependencyWrapperType.swift
//  
//
//  Created by Andres Duque on 20/05/24.
//

import Foundation

/// To define a dependency wrapper behavior.
enum DependencyWrapperType {
    /// For simple injections where implementations does not change dynamically.
    case regular
    /// For complex injections where implementations has to listen for changes dynamically.
    case observed
}
