//
//  DependenciesInjectorMacro.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 29/01/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

/// A Swift macro that generates extensions to inject and manage dependencies for a type.
///
/// DependenciesInjectorMacro is an extension macro that attaches to a declaration and
/// produces one or more extensions for the target type. It delegates its expansion logic
/// to a shared entry point using the `.dependenciesInjector` configuration, which allows
/// consistent behavior across related macros in this package.
///
/// Usage:
/// - Attach the corresponding attribute (e.g., `@DependenciesInjector`) to a type to have
///   the macro synthesize dependency-related boilerplate via generated extensions.
/// - The macro is invoked by the Swift compiler during macro expansion and will return
///   a collection of `ExtensionDeclSyntax` nodes that augment the annotated type.
///
/// Parameters (expansion):
/// - node: The attribute syntax that triggered this macro expansion.
/// - declaration: The declaration the attribute is attached to (e.g., a struct, class, or actor).
/// - type: The nominal type syntax the macro will extend.
/// - protocols: A list of protocols that the generated extension should conform to, if any.
/// - context: The macro expansion context provided by the compiler, used for diagnostics and unique naming.
///
/// Returns:
/// - An array of `ExtensionDeclSyntax` representing synthesized extensions that inject
///   dependency-related members or conformances into the target type.
///
/// Throws:
/// - Rethrows any error produced by the underlying expansion routine (e.g., validation or
///   syntax construction errors).
///
/// Notes:
/// - This macro depends on a shared `start` function and a `.dependenciesInjector` case
///   from a macro-kind or configuration type to centralize expansion behavior.
/// - Ensure that the associated attribute and any required supporting types are available
///   in the module where the macro is used to avoid expansion failures.
public struct DependenciesInjectorMacro: BaseExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax]  {
        return try start(
            for: .dependenciesInjector,
            of: node,
            providingMembersOf: declaration,
            providingExtensionsOf: type,
            conformingTo: protocols,
            in: context
        )
    }
}
