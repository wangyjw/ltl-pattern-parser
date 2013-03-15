// Generated from Ltl.g4 by ANTLR 4.0

package de.prob.ltl.parser;

import org.antlr.v4.runtime.tree.*;
import org.antlr.v4.runtime.Token;

public interface LtlVisitor<T> extends ParseTreeVisitor<T> {
	T visitParenthesisExpression(LtlParser.ParenthesisExpressionContext ctx);

	T visitConstant(LtlParser.ConstantContext ctx);

	T visitStart(LtlParser.StartContext ctx);

	T visitBinary_op(LtlParser.Binary_opContext ctx);

	T visitConstantExpression(LtlParser.ConstantExpressionContext ctx);

	T visitUnaryExpression(LtlParser.UnaryExpressionContext ctx);

	T visitUnary_op(LtlParser.Unary_opContext ctx);

	T visitBinaryExpression(LtlParser.BinaryExpressionContext ctx);
}