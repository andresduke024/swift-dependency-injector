//
//  InjectedConstructorMacroCreator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftSyntax

struct InjectedConstructorMacroCreator: BaseInjectedConstructorMacroCreator {
    var arguments: MemberMacroArguments
    
    init(arguments: MemberMacroArguments) {
        self.arguments = arguments
    }
    
    func create() throws -> [DeclSyntax] {
        return try create(with: nil)
    }
}
