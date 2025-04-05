//
//  RegistrationType.swift
//  
//
//  Created by Andres Duque on 12/07/23.
//

import Foundation

/// Defines the way to register dependencies into the container.
enum RegistrationType: Sendable {

    /// To add a new value into the container.
    case create

    /// To update an already stored value into the container.
    case update

    /// To add or update a value into the container.
    case updateOrCreate
}
