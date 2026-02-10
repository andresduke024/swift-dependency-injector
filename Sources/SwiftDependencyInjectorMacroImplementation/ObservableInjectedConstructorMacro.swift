//
//  ObservableInjectedConstructorMacro.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

/// A Swift macro that generates member declarations for types annotated to use an observable,
/// dependency-injected constructor pattern.
///
/// ObservableInjectedConstructorMacro is a member-providing macro that participates in macro
/// expansion for declaration groups (such as structs, classes, or actors). When applied as an
/// attribute to a declaration, it delegates to a shared expansion routine to synthesize the
/// appropriate members required by the "observable injected constructor" feature of this library.
///
/// Responsibilities:
/// - Hooks into the macro system as a BaseMemberMacro to provide additional members to the
///   annotated declaration.
/// - Invokes a common expansion pipeline (`start(for:of:providingMembersOf:conformingTo:in:)`)
///   with the `.observableInjectedConstructor` mode, ensuring consistent behavior across related
///   macros.
/// - Ensures conformance to any protocols passed during expansion if the generation logic requires it.
///
/// Parameters during expansion:
/// - node: The attribute syntax node that triggered this macro expansion.
/// - declaration: The declaration group (e.g., struct/class) receiving the synthesized members.
/// - protocols: A list of protocols the declaration is expected to conform to; may influence
///   the generated members depending on the shared expansion logic.
/// - context: The macro expansion context used to manage source locations and diagnostics.
///
/// Throws:
/// - Rethrows any errors produced by the shared expansion routine, including syntax validation
///   issues or diagnostics emitted during member synthesis.
///
/// Returns:
/// - An array of DeclSyntax representing the synthesized members to be injected into the annotated
///   declaration.
///
/// Usage:
/// - Apply the corresponding attribute (e.g., @ObservableInjectedConstructor) to a declaration.
///   The macro will synthesize the necessary members to support observable dependency-injected
///   initialization semantics.
///
/// Notes:
/// - The concrete generation logic is centralized in the shared `start` helper for consistency
///   across macros in this package. This macro simply selects the `.observableInjectedConstructor`
///   mode and forwards all relevant context.
/// - Diagnostics and source mappings are handled via SwiftDiagnostics and MacroExpansionContext to
///   provide precise error reporting and fix-its where applicable.
///
/// See also:
/// - BaseMemberMacro: The protocol this macro conforms to for member synthesis.
/// - `start(for:of:providingMembersOf:conformingTo:in:)`: The shared expansion entry point used
///   by this macro.
/// - `.observableInjectedConstructor`: The generation mode that drives what members are produced.
public struct ObservableInjectedConstructorMacro: BaseMemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return try start(
            for: .observableInjectedConstructor,
            of: node,
            providingMembersOf: declaration,
            conformingTo: protocols,
            in: context
        )
    }
}
