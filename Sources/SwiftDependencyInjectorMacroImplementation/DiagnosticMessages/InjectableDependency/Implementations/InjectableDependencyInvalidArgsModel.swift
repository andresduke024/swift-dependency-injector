//
//  InjectableDependencyInvalidArgsModel.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

protocol InjectableDependencyInvalidArgsModel: InjectableDependencyDiagnosticBase {}

extension InjectableDependencyInvalidArgsModel {
    var id: String { "InvalidInjectableDependencyArgsModel "}
}
