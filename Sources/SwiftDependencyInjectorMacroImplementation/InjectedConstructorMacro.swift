//
//  InjectedConstructor.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 6/01/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

/// A Swift macro that generates a convenience initializer for dependency injection.
///
/// InjectedConstructorMacro is a member-providing macro that, when attached to a type
/// (such as a struct or class), synthesizes an initializer tailored for dependency
/// injection. It inspects the annotated declaration and produces constructor members
/// according to the rules defined by the macro system in this package.
///
/// This macro delegates its core behavior to a shared expansion routine via `BaseMemberMacro`,
/// using the `.injectedConstructor` case to drive the specific generation logic. This keeps
/// the macro consistent with other member-generating macros in the project and centralizes
/// common validation, diagnostics, and code emission.
///
/// Usage:
/// - Attach the corresponding attribute (e.g., `@InjectedConstructor`) to a type that requires
///   an injected initializer.
/// - The macro will synthesize the appropriate initializer(s) at compile time, enabling
///   dependency injection without hand-written boilerplate.
///
/// Parameters handled during expansion:
/// - node: The attribute syntax node representing the macro annotation on the declaration.
/// - declaration: The declaration group (e.g., a type) to which members will be added.
/// - protocols: Any protocols the declaration is conforming to as part of this expansion.
/// - context: The macro expansion context used to emit diagnostics and manage generated code.
///
/// Throws:
/// - Rethrows any errors produced by the shared expansion routine if validation fails or
///   if code generation cannot proceed.
///
/// See also:
/// - `BaseMemberMacro` for the shared expansion infrastructure.
/// - `.injectedConstructor` case in the macro kind enumeration used to select behavior.
public struct InjectedConstructorMacro: BaseMemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return try start(
            for: .injectedConstructor,
            of: node,
            providingMembersOf: declaration,
            conformingTo: protocols,
            in: context
        )
    }
}
