//
//  InjectableDependencyInvalidArgsModelCase2.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

struct InjectableDependencyInvalidArgsModelCase2: InjectableDependencyInvalidArgsModel {
    var message: String { "First argument must be a protocol type ending with .self" }
}
