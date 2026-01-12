//
//  InjectedConstructorMacroCreator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

struct InjectedConstructorMacroCreator: MacroCreator {
    var arguments: MacroArguments
    
    init(arguments: MacroArguments) {
        self.arguments = arguments
    }
    
    func validate() throws -> Bool {
        let hasInitializer = ClassMemberValidatorFactory
            .get(.designedInitializer)
            .exists(for: arguments)
        
        if hasInitializer {
            diagnose(message: DesignedInitializerDiagnostic())
            return false
        }
        
        return true
    }
    
    func create() throws -> [DeclSyntax] {
        let dependencies = try parseDependencies()
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
    
    private func parseDependencies() throws -> [Dependency] {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            throw MacroError.invalidArguments
        }

        var dependencies: [Dependency] = []
        var seenSimpleTypes = Set<String>()

        for argument in arguments {
            let expr = argument.expression

            let dependency = try parseDependency(expr, &seenSimpleTypes)
            dependencies.append(dependency)
        }

        return dependencies
    }
    
    private func parseDependency(
        _ expr: ExprSyntax,
        _ seenSimpleTypes: inout Set<String>
    ) throws -> Dependency {
        if let dependency = parseTypeDependency(expr) {
            try validateDuplicateDependency(dependency: dependency, seenSimpleTypes: &seenSimpleTypes)
            return dependency
        }

        if let dependency = try parseConfiguredDependencyIfPossible(expr, in: context) {
            return dependency
        }

        diagnose(message: InvalidSelfTypeDiagnostic())
        throw MacroError.invalidDependency
    }
    
    private func validateDuplicateDependency(
        dependency: Dependency,
        seenSimpleTypes: inout Set<String>
    ) throws {
        if !seenSimpleTypes.insert(dependency.typeName).inserted {
            diagnose(message: DuplicateDependencyDiagnostic(typeName: dependency.typeName))
            throw MacroError.invalidDependency
        }
    }
    
    private func validateSelfTypeConformance(_ expr: SyntaxProtocol) -> DeclReferenceExprSyntax? {
        guard let memberAccess = expr.as(MemberAccessExprSyntax.self),
              memberAccess.declName.baseName.text == Constants.SintaxKeys.selfSintax,
              let base = memberAccess.base?.as(DeclReferenceExprSyntax.self)
        else { return nil }
        
        return base
    }
    
    private func parseTypeDependency(
        _ expr: ExprSyntax
    ) -> Dependency? {
        guard let base = validateSelfTypeConformance(expr) else { return nil }

        let typeName = base.baseName.text

        return Dependency(
            typeName: typeName,
            variableName: makeVariableName(from: typeName),
            injectionType: Constants.SintaxKeys.regularInjectionTypePropertyValue,
            constrainedTo: nil,
            source: .simple
        )
    }
    
    private func parseConfiguredDependencyIfPossible(
        _ expr: ExprSyntax,
        in context: some MacroExpansionContext
    ) throws -> Dependency? {

        guard let call = expr.as(FunctionCallExprSyntax.self),
              let callee = call.calledExpression.as(DeclReferenceExprSyntax.self),
              callee.baseName.text == Constants.SintaxKeys.dependencyClass
        else { return nil }

        return try parseConfiguredDependency(from: call, in: context)
    }

    private func parseConfiguredDependency(
        from call: FunctionCallExprSyntax,
        in context: some MacroExpansionContext
    ) throws -> Dependency {
        guard let firstArg = call.arguments.first else {
            throw MacroError.invalidDependency
        }

        guard let base = validateSelfTypeConformance(firstArg.expression) else {
            diagnose(message: MissingSelfDiagnostic())
            throw MacroError.invalidDependency
        }
        
        let typeName = base.baseName.text

        var injectionType: String? = nil
        var key: String? = nil
        var explicitVariableName: String? = nil

        for argument in call.arguments.dropFirst() {
            switch argument.label?.text {
            case Constants.SintaxKeys.injectionTypeProperty:
                injectionType = argument.expression.description.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            case Constants.SintaxKeys.constrainedToProperty:
                if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
                    key = stringLiteral.segments.description.replacingOccurrences(of: "\"", with: "")
                }
            case Constants.SintaxKeys.nameProperty:
                if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
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
            injectionType: injectionType ?? Constants.SintaxKeys.regularInjectionTypePropertyValue,
            constrainedTo: key,
            source: .configured
        )
    }
    
    private func makeVariableName(from typeName: String) -> String {
        typeName
            .removeSuffix(Constants.SintaxKeys.protocolSintax)
            .lowercasedFirst()
    }

    private func makeProperty(
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

    private func makeDependencyParameter(
        _ dependency: Dependency,
        isFirst: Bool
    ) -> FunctionParameterSyntax {
        let injectorCall = InjectorGetMethodBuilder(dependency: dependency).build()

        return makeParameter(
            isFirst: isFirst,
            name: dependency.variableName,
            type: IdentifierTypeSyntax(
                name: .identifier(dependency.typeName)
            ),
            defaultValue: InitializerClauseSyntax(
                value: ExprSyntax(injectorCall)
            )
        )
    }

    private func makeAssignment(
        name: String
    ) -> CodeBlockItemSyntax {

        let assignment = InfixOperatorExprSyntax(
            leftOperand: ExprSyntax(
                MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: .identifier(Constants.SintaxKeys.selfSintax)
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

    private func makeInitializer(
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

    private func makeParameterClause(
        _ dependencies: [Dependency],
        _ parameters: [InitParameter]
    ) -> FunctionParameterClauseSyntax {
        let hasParameters = !parameters.isEmpty
        
        let isFirst: (_ index: Int) -> Bool = { $0 == 0 }
        
        return FunctionParameterClauseSyntax {
            for (index, parameter) in parameters.enumerated() {
                makeInitParameter(parameter, isFirst: isFirst(index))
            }

            for (index, dependency) in dependencies.enumerated() {
                makeDependencyParameter(dependency, isFirst: !hasParameters && isFirst(index))
            }
        }

    }
    
    private func parseInitParameters(
        from declaration: some DeclGroupSyntax
    ) -> [InitParameter] {

        var parameters: [InitParameter] = []

        for member in declaration.memberBlock.members {
            guard
                let variable = member.decl.as(VariableDeclSyntax.self),
                let binding = variable.bindings.first,
                let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                let typeAnnotation = binding.typeAnnotation
            else { continue }

            let hasAttribute = variable.attributes.contains {
                $0.as(AttributeSyntax.self)?
                    .attributeName
                    .as(IdentifierTypeSyntax.self)?
                    .name.text == Constants.SintaxKeys.initParameterClass
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
    
    private func validateNoNameConflicts(
        parameters: [InitParameter],
        dependencies: [Dependency],
        context: some MacroExpansionContext,
        node: Syntax
    ) throws {
        let dependencyNames = Set(dependencies.map(\.variableName))

        for parameter in parameters {
            guard dependencyNames.contains(parameter.name) else { continue }
            
            diagnose(message: InitParameterNameConflictDiagnostic(name: parameter.name))
            throw MacroError.invalidDependency
        }
    }
    
    private func makeInitParameter(
        _ parameter: InitParameter,
        isFirst: Bool
    ) -> FunctionParameterSyntax {
        makeParameter(
            isFirst: isFirst,
            name: parameter.name,
            type: parameter.type
        )
    }
    
    private func makeParameter(
        isFirst: Bool,
        name: String,
        type: TypeSyntaxProtocol,
        defaultValue: InitializerClauseSyntax? = nil
    ) -> FunctionParameterSyntax {
        let leadingTrivia = isFirst
            ? (.newline + Constants.Trivia.defaultSpaces)
            : Constants.Trivia.defaultSpaces
        
        return FunctionParameterSyntax(
            leadingTrivia: leadingTrivia,
            firstName: .identifier(name),
            colon: .colonToken(trailingTrivia: .space),
            type: type,
            defaultValue: defaultValue,
            trailingComma: .commaToken(trailingTrivia: .newline)
        )
    }
}
