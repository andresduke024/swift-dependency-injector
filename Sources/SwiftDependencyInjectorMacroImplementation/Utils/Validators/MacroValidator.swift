//
//  ClassMemberValidator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A protocol that defines a validation contract for macro configurations and usage.
///
/// Conforming types are responsible for inspecting the parsed macro arguments and
/// determining whether they meet specific criteria before macro expansion proceeds.
/// This allows for early, composable validation of macro input and helps produce
/// clearer diagnostics when users provide incorrect or unsupported arguments.
///
/// Typical responsibilities of a `MacroValidator` include:
/// - Verifying the presence and correctness of required arguments.
/// - Enforcing mutually exclusive or dependent argument rules.
/// - Checking types, identifiers, or syntactic forms referenced by the macro.
///
/// Implementations should avoid performing side effects and focus solely on
/// validation. If validation fails, return `false` so the caller can emit
/// appropriate diagnostics.
///
/// - Note: This protocol is intended to be used within SwiftSyntax-based macro
///   implementations. It relies on a `MacroArguments` type that encapsulates the
///   macro’s parsed inputs.
///
/// - SeeAlso: `MacroArguments`
///
/// Usage:
/// - Create a type that conforms to `MacroValidator`.
/// - Implement `validate(for:)` to return `true` when the provided arguments are valid,
///   or `false` when they are not.
/// - Compose multiple validators if needed to build layered validation logic.
protocol MacroValidator {
    func validate(
        for arguments: MacroArguments
    ) -> Bool
}
