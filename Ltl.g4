grammar Ltl;

@lexer::header {
package de.prob.ltl.parser;
}

@parser::header {
package de.prob.ltl.parser;

import de.prob.ltl.parser.symboltable.SymbolTableManager;
}

@parser::members {
private SymbolTableManager symbolTableManager = new SymbolTableManager();

public SymbolTableManager getSymbolTableManager() {
	return symbolTableManager;
}
}

/* -- Rules -- */
start
 : (pattern_def | var_def | var_assign | loop)* expr
 ;

pattern_def
 : PATTERN_DEF ID LEFT_PAREN (pattern_def_param (',' pattern_def_param)*)? RIGHT_PAREN ':' pattern_def_body
 ;

pattern_def_body
 : (var_def | var_assign | loop)* expr
 ;
 
pattern_def_param
 : ID 				# varParam
 | ID ':' NUM_VAR	# numVarParam
 | ID ':' SEQ_VAR	# seqVarParam
 ;

pattern_call
 : ID LEFT_PAREN (var_value (',' var_value)*)? RIGHT_PAREN
 ;
 
scope_call
 : (BEFORE_SCOPE | AFTER_SCOPE) LEFT_PAREN var_value ',' var_value RIGHT_PAREN
 | (BETWEEN_SCOPE | UNTIL_SCOPE) LEFT_PAREN var_value ',' var_value ',' var_value RIGHT_PAREN
 ;
    
var_def
 : (VAR | NUM_VAR | SEQ_VAR) ID ':' var_value
 ;
 
var_assign
 : ID ':' var_value
 ;
 
var_value
 : ID								# varValue
 | NUM								# numValue
 | seq_value						# seqValue
 | LEFT_PAREN var_value RIGHT_PAREN	# parValue
 | expr								# exprValue
 ;
 
seq_value
 : LEFT_PAREN var_value (',' var_value)+ (SEQ_WITHOUT var_value)? RIGHT_PAREN	# seqValueDefinition
 | ID SEQ_WITHOUT var_value														# seqValueID
 ;
 
seq_call
 : SEQ_VAR LEFT_PAREN var_value RIGHT_PAREN												# seqCallSimple
 | SEQ_VAR LEFT_PAREN var_value (',' var_value)+ (SEQ_WITHOUT var_value)? RIGHT_PAREN	# seqCallDefinition
 ;
 
loop
 : LOOP_BEGIN (ID ':')? var_value (UP | DOWN) TO var_value ':' loop_body LOOP_END
 ;
 
loop_body
 : (var_def | var_assign)+
 ;
  
expr
 : NOT expr						# notExpr
 | GLOBALLY expr				# globallyExpr
 | FINALLY expr					# finallyExpr
 | NEXT expr					# nextExpr
 | HISTORICALLY expr			# historicallyExpr
 | ONCE expr					# onceExpr
 | YESTERDAY expr				# yesterdayExpr
 | UNARY_COMBINED expr			# unaryCombinedExpr
 | expr UNTIL expr				# untilExpr
 | expr WEAKUNTIL expr			# weakuntilExpr
 | expr RELEASE expr			# releaseExpr
 | expr SINCE expr				# sinceExpr
 | expr TRIGGER expr			# triggerExpr
 | expr AND expr				# andExpr
 | expr OR expr					# orExpr
 | expr IMPLIES expr			# impliesExpr
 | atom							# atomExpr
 ;
 
atom
 : ID							# variableCallAtom
 | pattern_call					# patternCallAtom	
 | scope_call					# scopeCallAtom
 | seq_call						# seqCallAtom
 | PREDICATE					# predicateAtom
 | ACTION						# actionAtom
 | ENABLED						# enabledAtom
 | LEFT_PAREN expr RIGHT_PAREN	# parAtom
 | (TRUE | FALSE) 				# booleanAtom
 | (SINK | DEADLOCK | CURRENT)	# stateAtom
 ;

/* -- Token -- */

// Constants
TRUE			: 'true';
FALSE			: 'false';
SINK			: 'sink';
DEADLOCK		: 'deadlock';
CURRENT			: 'current';

// Unary Ltl operators
GLOBALLY		: 'G';
FINALLY			: 'F';
NEXT			: 'X';
HISTORICALLY	: 'H';
ONCE			: 'O';
YESTERDAY		: 'Y';
UNARY_COMBINED 	: [GFXHOY]+;

// Binary Ltl operators
UNTIL			: 'U';
WEAKUNTIL		: 'W';
RELEASE			: 'R';
SINCE			: 'S';
TRIGGER			: 'T';

// Boolean operators
NOT				: 'not' | '!'; 
AND				: 'and' | '&';
OR				: 'or' | '|';
IMPLIES			: '=>';

// Unparsed 
PREDICATE		: LEFT_CURLY (~('{' | '}') | PREDICATE)* RIGHT_CURLY;
ACTION			: LEFT_BRACKET (~('[' | ']') | ACTION)* RIGHT_BRACKET;
ENABLED			: 'e' ENABLED_PAREN;
fragment 
ENABLED_PAREN	: LEFT_PAREN (~('(' | ')') | ENABLED_PAREN)* RIGHT_PAREN;

// Others
LEFT_CURLY		: '{';
RIGHT_CURLY		: '}';
LEFT_BRACKET	: '[';
RIGHT_BRACKET	: ']';
LEFT_PAREN		: '(';
RIGHT_PAREN		: ')';

// Comments
COMMENT			: ('//' ~('\n')* 
				| '/*' .*? '*/') -> skip;
				
// Patterns
PATTERN_DEF		: 'def';

// Scopes
BEFORE_SCOPE	: 'before';
AFTER_SCOPE		: 'after';
BETWEEN_SCOPE	: 'between';
UNTIL_SCOPE		: 'after_until';

// Vars
VAR				: 'var';
NUM_VAR			: 'num';
SEQ_VAR			: 'seq';

// Sequence
SEQ_WITHOUT		: 'without';

// Loops
LOOP_BEGIN		: 'count';
LOOP_END		: 'end';
UP				: 'up';
DOWN			: 'down';
TO				: 'to';
			
// Whitespaces
NUM				: '0' | [1-9] [0-9]*;
ID				: [a-zA-Z] [a-zA-Z0-9_]*;
WS				: [ \t\r\n]+ -> skip;