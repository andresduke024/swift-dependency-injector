//
//  MemberMacroCreator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 30/01/26.
//

import SwiftSyntax

/// A specialized macro-creator protocol for generating member declarations in a type.
///
/// `MemberMacroCreator` refines `MacroCreator` for macros that synthesize one or more
/// member declarations (e.g., properties, methods, initializers) inside the body of a
/// target type (struct, class, enum).
///
/// Conformance requirements:
/// - `T` is constrained to `MemberMacroArguments`, ensuring the creator receives all
///   context necessary to generate member-level declarations (such as the target type,
///   attributes, and configuration).
/// - Implement `create()` to produce the set of member declarations to be injected.
///
/// Typical usage:
/// - Parse and validate `MemberMacroArguments` (provided by `MacroCreator`).
/// - Build the desired members using SwiftSyntax nodes (e.g., `DeclSyntax`).
/// - Return the synthesized members from `create()`.
///
/// Error handling:
/// - `create()` can throw to surface validation or construction errors, which will
///   propagate to the macro expansion diagnostic system.
///
/// Returns:
/// - `create()` returns an array of `DeclSyntax` representing the synthesized members
///   to be inserted into the target type.
///
/// See also:
/// - `MacroCreator` for the base protocol and argument handling.
/// - `MemberMacroArguments` for the concrete argument type used by this protocol.
protocol MemberMacroCreator: MacroCreator where T == MemberMacroArguments {    
    func create() throws -> [DeclSyntax]
}
