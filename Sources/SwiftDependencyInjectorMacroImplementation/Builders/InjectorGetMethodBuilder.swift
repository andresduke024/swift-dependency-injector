//
//  InjectorGetMethodBuilder.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 12/01/26.
//

import SwiftSyntax

struct InjectorGetMethodBuilder {
    let dependency: Dependency
    
    func build() -> ExprSyntaxProtocol {

        return FunctionCallExprSyntax(
            calledExpression: ExprSyntax(
                MemberAccessExprSyntax(
                    base: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(
                            baseName: .identifier(Constants.SintaxKeys.injectorClass)
                        ),
                        name: .identifier(Constants.SintaxKeys.injectorGlobalProperty)
                    ),
                    name: .identifier(Constants.SintaxKeys.getMethod)
                )
            ),
            leftParen: .leftParenToken(),
            arguments: buildArguments(),
            rightParen: .rightParenToken()
        )
    }
    
    private func buildArguments() -> LabeledExprListSyntax {
        LabeledExprListSyntax {
            LabeledExprSyntax(
                label: .identifier(
                    Constants.SintaxKeys.injectionTypeProperty
                ),
                colon: .colonToken(),
                expression: ExprSyntax(
                    DeclReferenceExprSyntax(
                        baseName: .identifier(dependency.injectionType)
                    )
                )
            )

            if let key = dependency.constrainedTo {
                LabeledExprSyntax(
                    label: .identifier(
                        Constants.SintaxKeys.constrainedToProperty
                    ),
                    colon: .colonToken(),
                    expression: ExprSyntax(
                        StringLiteralExprSyntax(content: key)
                    )
                )
            }
        }
    }
}
