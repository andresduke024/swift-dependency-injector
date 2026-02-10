//
//  InitParameterMacro.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftSyntax
import SwiftSyntaxMacros

/// A marker macro used to annotate initializer parameters that must be supplied
/// explicitly when generating convenience initializers with other macros,
/// such as `@InjectedConstructor`.
///
/// This macro does not synthesize or transform any code by itself. Instead,
/// it serves purely as a semantic hint to companion macros that perform code
/// generation. For example, when a macro generates an initializer that injects
/// dependencies automatically, parameters marked with `@InitParameter` will be
/// treated as required, caller-provided arguments rather than injected values.
///
/// Usage:
/// - Apply `@InitParameter` directly to an initializer parameter to indicate
///   that it should not be automatically injected.
/// - Typically used in conjunction with an initializer-generating macro
///   (e.g., `@InjectedConstructor`) that inspects parameters and decides which
///   ones to inject versus require from the caller.
///
/// Behavior:
/// - Generates no peer declarations; expansion returns an empty list.
/// - Has no runtime effect; it is only a compile-time marker for macro systems.
///
/// Example:
/// ```swift
/// struct Service {
///     @Injected var client: APIClient
///
///     @InjectedConstructor
///     init(
///         @InitParameter baseURL: URL, // must be provided by the caller
///         timeout: TimeInterval = 30   // could be injected or defaulted
///     ) { ... }
/// }
/// ```
/// In the example above, a macro like `@InjectedConstructor` may generate a
/// convenience initializer that injects `client` automatically, preserves the
/// default for `timeout`, and requires `baseURL` to be passed explicitly by
/// the caller because it is marked with `@InitParameter`.
public struct InitParameterMacro: PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // This macro does NOT generate code.
        // It only acts as a marker for @InjectedConstructor.
        return []
    }
}
