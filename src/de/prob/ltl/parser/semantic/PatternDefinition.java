package de.prob.ltl.parser.semantic;

import java.util.LinkedList;
import java.util.List;

import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNode;

import de.prob.ltl.parser.LtlParser;
import de.prob.ltl.parser.LtlParser.LoopContext;
import de.prob.ltl.parser.LtlParser.NumVarParamContext;
import de.prob.ltl.parser.LtlParser.Pattern_defContext;
import de.prob.ltl.parser.LtlParser.Pattern_def_paramContext;
import de.prob.ltl.parser.LtlParser.SeqVarParamContext;
import de.prob.ltl.parser.LtlParser.VarParamContext;
import de.prob.ltl.parser.LtlParser.Var_assignContext;
import de.prob.ltl.parser.LtlParser.Var_defContext;
import de.prob.ltl.parser.symboltable.SymbolTable;
import de.prob.ltl.parser.symboltable.SymbolTableManager;
import de.prob.ltl.parser.symboltable.VariableTypes;

public class PatternDefinition extends SymbolTable {

	private final LtlParser parser;
	private final SymbolTableManager symbolTableManager;

	private Pattern_defContext context;
	private Token token;
	private String name;
	private List<Variable> parameters = new LinkedList<Variable>();

	public PatternDefinition(LtlParser parser, Pattern_defContext context) {
		super(parser.getSymbolTableManager().getCurrentScope());
		this.parser = parser;
		this.context = context;

		symbolTableManager = parser.getSymbolTableManager();

		if (this.context != null) {
			symbolTableManager.pushScope(this);
			determineTokenAndName();
			determineParameters();
			symbolTableManager.popScope();

			// Define pattern
			if (!symbolTableManager.define(this)) {
				parser.notifyErrorListeners(token, String.format("The pattern '%s' is already defined.", getName()), null);
			}
		}
	}

	public void checkBody() {
		symbolTableManager.pushScope(this);
		for (ParseTree child : context.pattern_def_body().children) {
			if (child instanceof Var_defContext) {
				// Define variable and check its initial value
				VariableDefinition definition = new VariableDefinition(parser, (Var_defContext) child);
				symbolTableManager.addNode(definition);
			} else if (child instanceof Var_assignContext) {
				// Check variable and its assigned value
				VariableAssignment assignment = new VariableAssignment(parser, (Var_assignContext) child);
				symbolTableManager.addNode(assignment);
			} else if (child instanceof LoopContext) {
				// Check loop with its count variable, arguments and body
				Loop loop = new Loop(parser, (LoopContext) child);
				symbolTableManager.addNode(loop);
			}
		}
		// Check final expr
		ExprOrAtom patternReturn = new ExprOrAtom(parser, context.pattern_def_body().expr());
		symbolTableManager.addNode(patternReturn);
		symbolTableManager.popScope();
	}

	private void determineTokenAndName() {
		TerminalNode node = context.ID();
		name = node.getText();
		token = node.getSymbol();
	}

	private void determineParameters() {
		for (Pattern_def_paramContext ctx : context.pattern_def_param()) {
			Variable parameter = null;
			if (ctx instanceof NumVarParamContext) {
				parameter = createVariable(((NumVarParamContext) ctx).ID(), VariableTypes.num);
			} else if (ctx instanceof SeqVarParamContext) {
				parameter = createVariable(((SeqVarParamContext) ctx).ID(), VariableTypes.seq);
			} else {
				parameter = createVariable(((VarParamContext) ctx).ID());
			}
			addParameter(parameters, parameter);
		}
	}

	private Variable createVariable(TerminalNode node, VariableTypes type) {
		String varName = node.getText();
		Variable var = new Variable(varName, type);
		var.setToken(node.getSymbol());
		return var;
	}

	private Variable createVariable(TerminalNode node) {
		return createVariable(node, VariableTypes.var);
	}

	private void addParameter(List<Variable> parameterList, Variable var) {
		parameterList.add(var);
		if (!symbolTableManager.define(var)) {
			parser.notifyErrorListeners(token, String.format("The variable '%s' is already defined in this scope.", var.getName()), null);
		}
	}

	public String getName() {
		return createIdentifier(name, parameters);
	}

	private static void printParam(StringBuilder sb, VariableTypes type, int count) {
		sb.append(type.toString());
		if (count > 1) {
			sb.append(count);
		}
	}

	public static String createIdentifier(String name, List<Variable> parameters) {
		StringBuilder sb = new StringBuilder(name);
		sb.append('/');
		if (parameters.size() == 0) {
			sb.append(0);
		} else {
			VariableTypes lastType = parameters.get(0).getType();
			int count = 1;
			for (int i = 1; i < parameters.size(); i++) {
				VariableTypes current = parameters.get(i).getType();
				if (lastType.equals(current)) {
					count++;
				} else {
					printParam(sb, lastType, count);
					lastType = current;
					count = 1;
				}
			}
			printParam(sb, lastType, count);
		}
		return sb.toString();
	}

	// Getters
	public Pattern_defContext getContext() {
		return context;
	}

	public Token getToken() {
		return token;
	}

	public String getSimpleName() {
		return name;
	}

	public List<Variable> getParameters() {
		return parameters;
	}

	@Override
	public String toString() {
		return getName();
	}

}
