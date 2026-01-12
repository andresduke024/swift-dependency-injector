//
//  ClassMemberValidator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

protocol ClassMemberValidator {
    func exists(
        for arguments: MacroArguments
    ) -> Bool
}
