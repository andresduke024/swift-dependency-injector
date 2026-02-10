//
//  ArgumentsExistanceValidator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 30/01/26.
//

import SwiftSyntax

/// Validates that a macro invocation includes at least one argument.
///
/// `ArgumentsExistenceValidator` conforms to `MacroValidator` and inspects the
/// provided `MacroArguments` to determine whether the underlying syntax node
/// contains any labeled expressions (i.e., arguments).
///
/// Behavior:
/// - Returns `true` when the macro has one or more arguments.
/// - Returns `false` when there are no arguments or the arguments list is absent.
///
/// Typical usage is within a validation pipeline for macros that require
/// arguments to function correctly.
///
/// - Note: This validator operates on `SwiftSyntax` constructs and expects
///   `MacroArguments.node.arguments` to be representable as a `LabeledExprListSyntax`.
///   If the cast fails or the list is empty, validation fails.
struct ArgumentsExistenceValidator: MacroValidator {
    func validate(
        for arguments: MacroArguments
    ) -> Bool {
        let macroArguments = arguments.node.arguments?.as(
            LabeledExprListSyntax.self
        )
        
        return macroArguments?.isEmpty == false
    }
}
