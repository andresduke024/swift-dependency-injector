//
//  ObservableInjectedConstructorMacroCreator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

import SwiftSyntax

struct ObservableInjectedConstructorMacroCreator: BaseInjectedConstructorMacroCreator {
    var arguments: MemberMacroArguments
    
    private let observationIgnoredAttribute = AttributeSyntax(
        attributeName: IdentifierTypeSyntax(
            name: .identifier(Constants.SintaxKeys.observationIgnoredMacro)
        )
    )
    
    init(arguments: MemberMacroArguments) {
        self.arguments = arguments
    }
    
    func create() throws -> [DeclSyntax] {
        let attributes = [
            observationIgnoredAttribute
        ]
        
        return try create(with: attributes)
    }
}
