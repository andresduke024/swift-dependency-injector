//
//  InjectableDependencyMacro.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 29/01/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

/// A Swift macro that generates boilerplate to make a type an injectable dependency.
///
/// Use `@InjectableDependency` on a type (typically a protocol or a concrete
/// service type) to automatically synthesize the extensions and conformance
/// required by the dependency injection system in this package.
/// The macro delegates most of the heavy lifting to a shared expansion routine
/// via `BaseExtensionMacro.start(for:of:providingMembersOf:providingExtensionsOf:conformingTo:in:)`,
/// passing `.injectableDependency` to indicate which feature set to synthesize.
///
/// Behavior
/// - Attaches generated extensions to the annotated type so it can participate
///   in dependency lookup and registration.
/// - May add protocol conformances and helper members as defined by the
///   `.injectableDependency` case in the shared macro implementation.
/// - Keeps your source minimal by avoiding repetitive, hand-written glue code.
///
/// Parameters
/// - node: The `@InjectableDependency` attribute syntax attached to the declaration.
/// - declaration: The declaration (e.g., a protocol or struct/class) the attribute is attached to.
/// - type: The type the macro will extend with synthesized members or conformances.
/// - protocols: Any protocols the generated extension should conform to.
/// - context: The macro expansion context provided by the compiler.
///
/// Returns
/// An array of `ExtensionDeclSyntax` nodes representing the synthesized extensions
/// that enable dependency injection for the annotated type.
///
/// Throws
/// Rethrows any diagnostics-producing errors from the shared expansion routine
/// if the macro cannot produce a valid expansion.
///
/// Usage
/// ```swift
/// @InjectableDependency
/// protocol AnalyticsClient {
///     func track(event: String)
/// }
/// ```
///
/// Notes
/// - This macro requires SwiftSyntax-based macro support and is intended to be
///   used within SwiftPM/Xcode projects that enable macros.
/// - The exact generated API surface depends on the implementation behind
///   `.injectableDependency` in the shared `BaseExtensionMacro` helper.
public struct InjectableDependencyMacro: BaseExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax]  {
        return try start(
            for: .injectableDependency,
            of: node,
            providingMembersOf: declaration,
            providingExtensionsOf: type,
            conformingTo: protocols,
            in: context
        )
    }
}
