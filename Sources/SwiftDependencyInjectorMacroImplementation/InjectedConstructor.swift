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

enum MacroError: Error {
    case invalidArguments
    case invalidDependency
}

public struct InjectedConstructor: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if hasInitializer(in: declaration) {
            diagnoseInitializerExists(
                on: Syntax(declaration),
                context: context
            )
            return []
        }
        
        let dependencies = try parseDependencies(from: node, in: context)
        let initParameters = parseInitParameters(from: declaration)

        try validateNoNameConflicts(
            parameters: initParameters,
            dependencies: dependencies,
            context: context,
            node: Syntax(declaration)
        )

        let properties = dependencies.map(makeProperty)

        let initializer = makeInitializer(
            dependencies: dependencies,
            parameters: initParameters
        )

        return properties.map(DeclSyntax.init) + [
            DeclSyntax(initializer)
        ]
    }
    
    private static func parseDependencies(
        from node: AttributeSyntax,
        in context: some MacroExpansionContext
    ) throws -> [Dependency] {

        guard
            let arguments = node.arguments?.as(LabeledExprListSyntax.self)
        else {
            throw MacroError.invalidArguments
        }

        var dependencies: [Dependency] = []
        var seenSimpleTypes = Set<String>()

        for argument in arguments {
            let expr = argument.expression

            // 1️⃣ Type.self
            if let dependency = parseTypeDependency(expr) {

                // ❌ Duplicados solo para dependencias simples
                if !seenSimpleTypes.insert(dependency.typeName).inserted {
                    context.diagnose(
                        Diagnostic(
                            node: Syntax(expr),
                            message: DuplicateDependencyDiagnostic(
                                typeName: dependency.typeName
                            )
                        )
                    )
                    throw MacroError.invalidDependency
                }

                dependencies.append(dependency)
                continue
            }

            // 2️⃣ Dependency(...)
            if let dependency = try parseConfiguredDependencyIfPossible(
                expr,
                in: context
            ) {
                dependencies.append(dependency)
                continue
            }

            // ❌ Sintaxis inválida
            context.diagnose(
                Diagnostic(
                    node: Syntax(expr),
                    message: InvalidDependencyDiagnostic(
                        message: """
                        Invalid dependency. Only `Type.self` or \
                        `Dependency(Type.self, ...)` are allowed.
                        """
                    )
                )
            )

            throw MacroError.invalidDependency
        }

        return dependencies
    }
    
    
    private static func parseTypeDependency(
        _ expr: ExprSyntax
    ) -> Dependency? {

        guard
            let memberAccess = expr.as(MemberAccessExprSyntax.self),
            memberAccess.declName.baseName.text == "self",
            let base = memberAccess.base?.as(DeclReferenceExprSyntax.self)
        else {
            return nil
        }

        let typeName = base.baseName.text

        return Dependency(
            typeName: typeName,
            variableName: makeVariableName(from: typeName),
            injectionType: ".regular",
constrainedTo: nil,
            source: .simple
        )
    }

    
    private static func parseConfiguredDependencyIfPossible(
        _ expr: ExprSyntax,
        in context: some MacroExpansionContext
    ) throws -> Dependency? {

        guard
            let call = expr.as(FunctionCallExprSyntax.self),
            let callee = call.calledExpression
                .as(DeclReferenceExprSyntax.self),
            callee.baseName.text == "Dependency"
        else {
            return nil
        }

        return try parseConfiguredDependency(from: call, in: context)
    }


    
    private static func parseConfiguredDependency(
        from call: FunctionCallExprSyntax,
        in context: some MacroExpansionContext
    ) throws -> Dependency {

        // Debe llamarse Dependency(...)
        guard
            let identifier = call.calledExpression
                .as(DeclReferenceExprSyntax.self),
            identifier.baseName.text == "Dependency"
        else {
            throw MacroError.invalidDependency
        }

        // Primer argumento obligatorio
        guard let firstArg = call.arguments.first else {
            throw MacroError.invalidDependency
        }

        // Debe ser Type.self
        guard
            let memberAccess = firstArg.expression
                .as(MemberAccessExprSyntax.self),
            memberAccess.declName.baseName.text == "self",
            let base = memberAccess.base?
                .as(DeclReferenceExprSyntax.self)
        else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(firstArg.expression),
                    message: MissingSelfDiagnostic()
                )
            )
            throw MacroError.invalidDependency
        }

        let typeName = base.baseName.text

        var injectionType = ".regular"
        var key: String? = nil
        var explicitVariableName: String? = nil

        // Argumentos con label
        for argument in call.arguments.dropFirst() {
            switch argument.label?.text {
            case "injectionType":
                injectionType = argument.expression.description.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            case "constrainedTo":
                if let stringLiteral = argument.expression
                    .as(StringLiteralExprSyntax.self) {
                    key = stringLiteral.segments.description
                        .replacingOccurrences(of: "\"", with: "")
                }
            case "name":
                if let stringLiteral = argument.expression
                    .as(StringLiteralExprSyntax.self) {
                    explicitVariableName = stringLiteral.segments
                        .compactMap { $0.as(StringSegmentSyntax.self)?.content.text }
                        .joined()
                }
            default:
                break
            }
        }

        return Dependency(
            typeName: typeName,
            variableName: explicitVariableName ?? makeVariableName(from: typeName),
            injectionType: injectionType,
            constrainedTo: key,
            source: .configured
        )
    }
    
    private static func makeVariableName(from typeName: String) -> String {
        let sanitizedTypeName: String

        if typeName.hasSuffix("Protocol") {
            sanitizedTypeName = String(
                typeName.dropLast("Protocol".count)
            )
        } else {
            sanitizedTypeName = typeName
        }

        return lowercasedFirst(sanitizedTypeName)
    }


    private static func lowercasedFirst(_ string: String) -> String {
        string.prefix(1).lowercased() + string.dropFirst()
    }

    private static func makeProperty(
        _ dependency: Dependency
    ) -> VariableDeclSyntax {

        VariableDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.private))
            },
            bindingSpecifier: .keyword(.let)
        ) {
            PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(
                    identifier: .identifier(dependency.variableName)
                ),
                typeAnnotation: TypeAnnotationSyntax(
                    type: IdentifierTypeSyntax(
                        name: .identifier(dependency.typeName)
                    )
                )
            )
        }
    }

    private static func makeDependencyParameter(
        _ dependency: Dependency,
        isFirst: Bool
    ) -> FunctionParameterSyntax {

        let arguments = LabeledExprListSyntax {
            LabeledExprSyntax(
                label: .identifier("injectionType"),
                colon: .colonToken(),
                expression: ExprSyntax(
                    DeclReferenceExprSyntax(
                        baseName: .identifier(dependency.injectionType)
                    )
                )
            )

            if let key = dependency.constrainedTo {
                LabeledExprSyntax(
                    label: .identifier("constrainedTo"),
                    colon: .colonToken(),
                    expression: ExprSyntax(
                        StringLiteralExprSyntax(content: key)
                    )
                )
            }
        }

        let injectorCall = FunctionCallExprSyntax(
            calledExpression: ExprSyntax(
                MemberAccessExprSyntax(
                    base: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(
                            baseName: .identifier("Injector")
                        ),
                        name: .identifier("global")
                    ),
                    name: .identifier("get")
                )
            ),
            leftParen: .leftParenToken(),
            arguments: arguments,
            rightParen: .rightParenToken()
        )

        return FunctionParameterSyntax(
            leadingTrivia: isFirst ? (.newline + .spaces(4)) : .spaces(4),
            firstName: .identifier(dependency.variableName),
            colon: .colonToken(trailingTrivia: .space),
            type: IdentifierTypeSyntax(
                name: .identifier(dependency.typeName)
            ),
            defaultValue: InitializerClauseSyntax(
                value: ExprSyntax(injectorCall)
            ),
            trailingComma: .commaToken(trailingTrivia: .newline)
        )
    }

    private static func makeAssignment(
        name: String
    ) -> CodeBlockItemSyntax {

        let assignment = InfixOperatorExprSyntax(
            leftOperand: ExprSyntax(
                MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier("self")
                    ),
                    name: .identifier(name)
                )
            ),
            operator: BinaryOperatorExprSyntax(
                operator: .equalToken()
            ),
            rightOperand: ExprSyntax(
                DeclReferenceExprSyntax(
                    baseName: .identifier(name)
                )
            )
        )

        return CodeBlockItemSyntax(
            item: .stmt(
                StmtSyntax(
                    ExpressionStmtSyntax(expression: ExprSyntax(assignment))
                )
            )
        )
    }

    private static func makeInitializer(
        dependencies: [Dependency],
        parameters: [InitParameter]
    ) -> InitializerDeclSyntax {

        let parameterClause = makeParameterClause(dependencies, parameters)
        
        let body = CodeBlockSyntax {

            for parameter in parameters {
                makeAssignment(name: parameter.name)
            }

            for dependency in dependencies {
                makeAssignment(name: dependency.variableName)
            }
        }

        return InitializerDeclSyntax(
            signature: FunctionSignatureSyntax(
                parameterClause: parameterClause
            ),
            body: body
        )
    }

    private static func makeParameterClause(
        _ dependencies: [Dependency],
        _ parameters: [InitParameter]
    ) -> FunctionParameterClauseSyntax {
        let hasParameters = !parameters.isEmpty
        
        return FunctionParameterClauseSyntax {

            // TODO: RESOLVE FIRST WHEN HAS INIT EN DEPENDENCY PARAMETERS
            for (index, parameter) in parameters.enumerated() {
                makeInitParameter(parameter, isFirst: index == 0)
            }

            for (index, dependency) in dependencies.enumerated() {
                makeDependencyParameter(dependency, isFirst: !hasParameters && index == 0)
            }
        }

    }
    
    
    private static func hasInitializer(
        in declaration: some DeclGroupSyntax
    ) -> Bool {
        declaration.memberBlock.members.contains { member in
            guard let initializer = member.decl.as(InitializerDeclSyntax.self) else {
                return false
            }

            let isConvenience = initializer.modifiers.contains(
                where: { $0.name.tokenKind == .keyword(.convenience) }
            )

            return !isConvenience
        }
    }
    
    private static func diagnoseInitializerExists(
        on node: Syntax,
        context: some MacroExpansionContext
    ) {
        context.diagnose(
            Diagnostic(
                node: node,
                message: InjectedConstructorDiagnostic(
                    message: """
                    @InjectedConstructor cannot be applied because \
                    the type already defines a designed initializer.
                    """
                )
            )
        )
    }
    
    private static func parseInitParameters(
        from declaration: some DeclGroupSyntax
    ) -> [InitParameter] {

        var parameters: [InitParameter] = []

        for member in declaration.memberBlock.members {
            guard
                let variable = member.decl.as(VariableDeclSyntax.self),
                let binding = variable.bindings.first,
                let identifier = binding.pattern
                    .as(IdentifierPatternSyntax.self),
                let typeAnnotation = binding.typeAnnotation
            else { continue }

            let hasAttribute = variable.attributes.contains {
                $0.as(AttributeSyntax.self)?
                    .attributeName
                    .as(IdentifierTypeSyntax.self)?
                    .name.text == "InitParameter"
            }

            guard hasAttribute else { continue }

            parameters.append(
                InitParameter(
                    name: identifier.identifier.text,
                    type: typeAnnotation.type
                )
            )
        }

        return parameters
    }
    
    private static func validateNoNameConflicts(
        parameters: [InitParameter],
        dependencies: [Dependency],
        context: some MacroExpansionContext,
        node: Syntax
    ) throws {

        let dependencyNames = Set(dependencies.map(\.variableName))

        for parameter in parameters {
            if dependencyNames.contains(parameter.name) {
                context.diagnose(
                    Diagnostic(
                        node: node,
                        message: InvalidDependencyDiagnostic(
                            message: """
                            InitParameter '\(parameter.name)' conflicts \
                            with injected dependency name.
                            """
                        )
                    )
                )
                throw MacroError.invalidDependency
            }
        }
    }
    
    private static func makeInitParameter(
        _ parameter: InitParameter,
        isFirst: Bool
    ) -> FunctionParameterSyntax {

        FunctionParameterSyntax(
            leadingTrivia: isFirst ? (.newline + .spaces(4)) : .spaces(4),
            firstName: .identifier(parameter.name),
            colon: .colonToken(trailingTrivia: .space),
            type: parameter.type,
            trailingComma: .commaToken(trailingTrivia: .newline)
        )
    }
}

struct InitParameter {
    let name: String
    let type: TypeSyntax
}

enum DependencySource {
    case simple
    case configured
}

struct Dependency {
    let typeName: String
    let variableName: String
    let injectionType: String
    let constrainedTo: String?
    let source: DependencySource
}

struct InjectedConstructorDiagnostic: DiagnosticMessage {
    let message: String
    let diagnosticID = MessageID(
        domain: "InjectedConstructor",
        id: "initializer-exists"
    )
    let severity: DiagnosticSeverity = .error
}

struct InvalidDependencyDiagnostic: DiagnosticMessage {
    let message: String

    var diagnosticID: MessageID {
        MessageID(domain: "InjectedConstructorMacro", id: "InvalidDependency")
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

struct MissingSelfDiagnostic: DiagnosticMessage {
    var diagnosticID: MessageID {
        MessageID(
            domain: "InjectedConstructorMacro",
            id: "MissingSelf"
        )
    }

    var severity: DiagnosticSeverity {
        .error
    }

    var message: String {
        "Dependency must be declared using `Type.self`"
    }
}

struct DuplicateDependencyDiagnostic: DiagnosticMessage {
    let typeName: String

    var diagnosticID: MessageID {
        MessageID(
            domain: "InjectedConstructorMacro",
            id: "DuplicateDependency"
        )
    }

    var severity: DiagnosticSeverity {
        .error
    }

    var message: String {
        "Duplicate dependency `\(typeName)` declared directly. Remove the duplicate or use `Dependency(...)`."
    }
}
