//
//  DesignedInitializerValidator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct DesignedInitializerValidator: ClassMemberValidator {
    func exists(
        for arguments: MacroArguments
    ) -> Bool {
        arguments.declaration.memberBlock.members.contains { member in
            guard let initializer = member.decl.as(InitializerDeclSyntax.self) else {
                return false
            }

            let isConvenience = initializer.modifiers.contains(
                where: { $0.name.tokenKind == .keyword(.convenience) }
            )

            return !isConvenience
        }
    }
}
