module EXPR-SYNTAX
    imports INT
    imports BOOL
    imports ID

    syntax Enum ::= Id "." Id

    syntax Value ::= Int | Bool | Enum
    syntax KResult ::= Value

    syntax Expr ::= Value
                  | Id
                  | ".Expr"
                  | "(" Expr ")" [bracket]
                  > "-" Expr [seqstrict]
                  | "+" Expr [seqstrict]
                  > Expr "*"  Expr [left, seqstrict(1, 2)]
                  | Expr "/"  Expr [left, seqstrict]
                  > Expr "+"  Expr [left, seqstrict]
                  | Expr "-"  Expr [left, seqstrict]
                  > Expr ">"  Expr [left, seqstrict]
                  | Expr ">=" Expr [left, seqstrict]
                  | Expr "<"  Expr [left, seqstrict]
                  | Expr "<=" Expr [left, seqstrict]
                  > Expr "==" Expr [left, seqstrict]
                  | Expr "!=" Expr [left, seqstrict]
                  > "!" Expr       [seqstrict]
                  > Expr "&&" Expr [left, seqstrict]
                  > Expr "||" Expr [left, seqstrict]
endmodule

module XSTS-SYNTAX
    imports INT-SYNTAX
    imports BOOL-SYNTAX
    imports ID-SYNTAX
    imports EXPR-SYNTAX

    //syntax Enum ::= Id "." Id

    syntax Enums ::= List{Id, ","}
    syntax TypeDeclaration ::= "type" Id ":" "{" Enums "}"
    
    syntax TypeName ::= "integer" | "boolean" | Id
    syntax VariableDeclaration ::= "var" Id ":" TypeName
                                 | "var" Id ":" TypeName "=" Expr [strict(3)]

    syntax Assignment ::= Id ":=" Expr ";" [strict(2)]
    syntax Havoc ::= "havoc" Id ";" 
    syntax Assumption ::= "assume" Expr ";" [strict(1)] //Value from Expr, lehet Expr, literalExpression vagy ReferenceExpression

    syntax Operation ::= Choice
                       | Assignment
                       | Havoc
                       | Assumption
    
    syntax Block ::= "{" Sequence "}"
    syntax OrBlocks ::= List{Block, "or"}
    syntax Choice ::= "choice" OrBlocks
    
    syntax Sequence ::= List{Operation, ""}

    syntax Transition ::= "trans" "{" Sequence "}"
    syntax Init ::= "init" "{" Sequence "}"
    syntax Env ::= "env" "{" Sequence "}"
    syntax Prop ::= "prop" "{" Expr "}" | "prop" "{" "}"

    syntax Declaration ::= VariableDeclaration | TypeDeclaration
    syntax Declarations ::= List{Declaration, ""}

    syntax Program ::= Declarations Transition Init Env Prop
                     | Declarations //temp
endmodule

module PROJECT-SYNTAX
    imports XSTS-SYNTAX
endmodule

module CONFIGURATION
    imports PROJECT-SYNTAX

    syntax Expr ::= ".Prop"
    syntax Status ::= "START" 
                    | "DECLARATIONS"
                    | "INIT"
                    | "TRAN"
                    | "ENV"
                    | "RUNNER"
                    | "PROPERTY-EVALUATION-OR-FAIL"
                    | "PROPERTY-SUCCESS"
                    | "PROPERTY-FAIL"
                    | "NO-RETURN"

    syntax Bool ::= isFail( Status ) [function]
                  | isEnumType( TypeName ) [function]

    rule isFail( PROPERTY-FAIL ) => true
    rule isFail( _ ) => false [owise]

    rule isEnumType( integer ) => false
    rule isEnumType( boolean ) => false
    rule isEnumType( _ ) => true [owise]

    configuration <T>
        <k> $PGM:Program </k>
        <state>
            <property> .Prop </property>
            <enum-definitions> .Map </enum-definitions>
            <variable-types> .Map </variable-types>
            <transition> .K </transition>
            <init> .K </init>
            <env> .K </env>
            <variable-values> .Map </variable-values>
        </state>
        <linking>
            <linking-declarations> .K </linking-declarations>
        </linking>
        <runner> .K </runner>
        <status> START </status>
        <return-status> NO-RETURN </return-status>
    </T>

    /* status key:
    0: program linking
    1: declaration semantics
    2: init block
    3: tran block
    4: env block
    100: transitions runner
    101: property evaluation in progress or evaluated to false
    102: property evaluated

    return status: -1 means no return expected
    */

    /* semantic sorts */
    syntax Assumption ::= "assume" "#active" ";"
    syntax Active ::= "#active" "(" KItem ")"
endmodule

module EXPR-RULES
    imports EXPR-SYNTAX
    imports CONFIGURATION
    imports MAP
    imports STRING

    rule [expr-variable-lookup]: <k> X:Id => VARIABLES [X] ...</k>
         <variable-values> VARIABLES </variable-values> requires X in_keys ( VARIABLES )
    
    rule [expr-int-mul]: <k> I1:Int * I2:Int => I1 *Int I2 ...</k>
    rule [expr-int-div]: <k> I1:Int / I2:Int => I1 /Int I2 ...</k>
    rule [expr-int-add]: <k> I1:Int + I2:Int => I1 +Int I2 ...</k>
    rule [expr-int-sub]: <k> I1:Int - I2:Int => I1 -Int I2 ...</k>
    rule [expr-int-grt]: <k> I1:Int > I2:Int => I1 >Int I2 ...</k>
    rule [expr-int-gte]: <k> I1:Int >= I2:Int => I1 >=Int I2 ...</k>
    rule [expr-int-lst]: <k> I1:Int < I2:Int => I1 <Int I2 ...</k>
    rule [expr-int-lte]: <k> I1:Int <= I2:Int => I1 <=Int I2 ...</k>
    rule [expr-int-equ]: <k> I1:Int == I2:Int => I1 ==Int I2 ...</k>
    rule [expr-int-ueq]: <k> I1:Int != I2:Int => I1 =/=Int I2 ...</k>
    rule [expr-bool-equ]: <k> B1:Bool == B2:Bool => B1 ==Bool B2 ...</k>
    rule [expr-bool-ueq]: <k> B1:Bool != B2:Bool => B1 =/=Bool B2 ...</k>
    rule [expr-bool-or]: <k> B1:Bool || B2:Bool => B1 orBool B2 ...</k>
    rule [expr-bool-and]: <k> B1:Bool && B2:Bool => B1 andBool B2 ...</k>
    rule [expr-enum-equ]: <k> X1:Id.X2:Id == X3:Id.X4:Id => (Id2String(X1) ==String Id2String(X3)) andBool (Id2String(X2) ==String Id2String(X4)) ... </k>
    rule [expr-enum-ueq]: <k> X1:Id.X2:Id != X3:Id.X4:Id => (Id2String(X1) =/=String Id2String(X3)) orBool (Id2String(X2) =/=String Id2String(X4)) ... </k>
    
    rule [expr-int-unary-neg]: <k> - I:Int  => 0 -Int I ... </k>
    rule [expr-int-unary-pos]: <k> + I:Int  => I ... </k>
    rule [expr-bool-negate]: <k> ! B:Bool => notBool B ... </k>
endmodule

module PROGRAM-LINKING
    imports CONFIGURATION
    imports PROJECT-SYNTAX
    imports EXPR-RULES
    imports INT

    rule [TEST-simplified-input]: <k> D:Declarations => D:Declarations trans { .Sequence } init { .Sequence } env { .Sequence } prop { true } </k>

    rule [store-input-file-in-config]: <k> D:Declarations trans { T:Sequence } init { I:Sequence } env { E:Sequence } prop { P:Expr } => .K </k>
        <linking-declarations> .K => D </linking-declarations>
        <transition> .K => T </transition>
        <init> .K => I </init>
        <env> .K => E </env>
        <property> .Prop => P </property>
        <status> START => DECLARATIONS </status>
endmodule

module DECLARATIONS
    imports CONFIGURATION
    imports PROJECT-SYNTAX
    imports BOOL

    //types
    rule [select-next-type-declaration]: <linking-declarations> T:TypeDeclaration D:Declarations => T ~> D ... </linking-declarations>
         <status> DECLARATIONS </status>

    rule [store-type-declaration]: <linking-declarations> type I:Id : { E:Enums } => .K ... </linking-declarations>
         <enum-definitions> ENUMS => ENUMS [ I <- E ] </enum-definitions>
         <status> DECLARATIONS </status>

    rule [select-next-variable-declaration]: <linking-declarations> V:VariableDeclaration D:Declarations => V ~> D ... </linking-declarations>
         <status> DECLARATIONS </status>

    //variables
    rule [variable-uninit-int]: <linking-declarations> var I:Id : integer => .K ... </linking-declarations>
         <variable-values> VALUES => VALUES [ I <- ?_:Int ] </variable-values>
         <variable-types> TYPES => TYPES [ I <- integer ] </variable-types>
         <status> DECLARATIONS </status>

    rule [variable-uninit-bool]: <linking-declarations> var I:Id : boolean => .K ... </linking-declarations>
         <variable-values> VALUES => VALUES [ I <- ?_:Bool ] </variable-values>
         <variable-types> TYPES => TYPES [ I <- boolean ] </variable-types>
         <status> DECLARATIONS </status>

    rule [variable-uninit-enum]: <linking-declarations> var I:Id : T:Id => .K ... </linking-declarations>
         <variable-values> VALUES => VALUES [ I <- ?_:Enum ] </variable-values>
         <variable-types> TYPES => TYPES [ I <- T ] </variable-types>
         <status> DECLARATIONS </status> 

    rule [variable-init-unwrap]: <linking-declarations> var I:Id : T:TypeName = E:Expr => #active( var I : T ) ... </linking-declarations>
         <k> .K => E </k>
         <status> DECLARATIONS </status>

    rule [variable-init-store]: <linking-declarations> #active( var I:Id : T:TypeName ) => .K ... </linking-declarations>
         <k> V:Value => .K </k>
         <variable-values> VALUES => VALUES [ I <- V ] </variable-values>
         <variable-types> TYPES => TYPES [ I <- T ] </variable-types>
         <status> DECLARATIONS </status>

    //cleanup
    rule [declarations-cleanup-and-next]: <linking-declarations> .Declarations => .K ... </linking-declarations>
         <status> DECLARATIONS => INIT </status>
endmodule

module TRAN-INIT
    imports CONFIGURATION
    imports PROJECT-SYNTAX

    //passing to runner
    rule [init-to-runner]: <init> E:Sequence => .K </init>
         <runner> .K => E </runner>
         <status> INIT => RUNNER </status>
         <return-status> NO-RETURN => INIT </return-status> [priority(100)]

    rule [init-to-tran]: <init> .K </init>
         <status> INIT => TRAN </status> [priority(100)]
    
endmodule

module TRAN-TRAN
    imports CONFIGURATION
    imports PROJECT-SYNTAX

    //passing to runner
    rule [tran-to-runner]: <transition> E:Sequence </transition>
         <runner> .K => E </runner>
         <status> TRAN => RUNNER </status>
         <return-status> NO-RETURN => ENV </return-status> [priority(100)]
         /* by passing in 4 as the return status, it will go to ENV next. This is not pretty, since this way it doesn't allow for any
         * closing operations after the running is done, but before we move on to env.
         * If closing operations are needed, it could possibly be done by <transition> E:... => active(E) </transition>
         * and a new rule <transition> active(E:...) => E </transition> <status> 3 => 4 </status> 
         * which would prevent looping
         */
    
endmodule

module TRAN-ENV
    imports CONFIGURATION
    imports PROJECT-SYNTAX

    //passing to runner
    rule [env-to-runner]: <env> E:Sequence </env>
         <runner> .K => E </runner>
         <status> ENV => RUNNER </status>
         <return-status> NO-RETURN => TRAN </return-status> [priority(100)]
         /* by passing in 3 as the return status, it will go to TRAN next. This is not pretty, since this way it doesn't allow for any
         * closing operations after the running is done, but before we move on to tran.
         * If closing operations are needed, it could possibly be done by <transition> E:... => active(E) </transition>
         * and a new rule <transition> active(E:...) => E </transition> <status> 4 => 3 </status> 
         * which would prevent looping
         */
    
endmodule

module RUN-TRANSITION
    imports CONFIGURATION
    imports PROJECT-SYNTAX
    imports BOOL
    imports EXPR-RULES
    imports K-EQUAL

    //prepare operations
    rule [select-next-operation]: <runner> O:Operation S:Sequence => O ~> S ... </runner>
         <status> RUNNER </status> 

    //assignment
    rule [assign-unwrap]: <runner> I:Id := E:Expr ; => #active( I ) ... </runner>
         <k> .K => E </k>
         <status> RUNNER </status>

    rule [assign-update]: <runner> #active( X:Id ) => .K ... </runner>
         <k> V:Value => .K </k>
         <variable-values> VALUES => VALUES [ X <- V ] </variable-values>
         <status> RUNNER </status> requires X in_keys( VALUES )

    //assume
    rule [assume-unwrap]: <runner> assume E:Expr ; => assume #active ; ... </runner>
         <k> .K => E </k>
         <status> RUNNER </status>
    
    rule [assume-true]: <runner> assume #active ; => .K ... </runner>
         <k> true => .K </k>
         <status> RUNNER </status> //remove assume true;s

    //havoc
    rule [havoc-int]: <runner> havoc X:Id ; => .K ... </runner>
         <variable-values> VALUES => VALUES [ X <- ?_:Int ] </variable-values>
         <variable-types>... X |-> integer ...</variable-types>
         <status> RUNNER </status> requires ( X in_keys( VALUES ) ) //andBool ( Id2String( TYPES [I] ) ==String "integer" ) 

    rule [havoc-bool]: <runner> havoc I:Id ; => .K ... </runner>
         <variable-values> VALUES => VALUES [ I <- ?_:Bool ] </variable-values>
         <variable-types>... I |-> boolean ...</variable-types>
         <status> RUNNER </status> requires ( I in_keys( VALUES ) ) //andBool ( Id2String( TYPES [I] ) ==String "boolean" ) 

    rule [havoc-enum]: <runner> havoc I:Id ; => .K ... </runner>
         <variable-values> VALUES => VALUES [ I <- ?_:Enum ] </variable-values>
         <variable-types>... I |-> ENUMTYPE ...</variable-types> 
         <status> RUNNER </status> 
         requires (I in_keys( VALUES )) andBool isEnumType( ENUMTYPE ) [owise]

    //choice
    rule [choice-unwrap]: <runner> choice O:OrBlocks => O ... </runner>
                          <status> RUNNER </status>

    //choice: nondet
    rule [choice-first]: <runner> { S:Sequence } or _:OrBlocks => S ... </runner>
                         <status> RUNNER </status>
    rule [choice-rest]: <runner> _:Block or O:OrBlocks => O ... </runner>
                        <status> RUNNER </status> requires O =/=K .OrBlocks

    //cleanup
    rule [runner-clean-sequence]: <runner> .Sequence => .K ... </runner>
         <status> RUNNER </status>

    //property verification
    rule [property-start]: <runner> .K </runner>
         <k> .K => PROP </k>
         <property> PROP:Expr </property>
         <status> RUNNER => PROPERTY-EVALUATION-OR-FAIL </status> [priority(200)] 
         //works without priority because there is no <runner>.K</runner> <status>100</status> state before this one

    //only exit runner if property is true
    rule [property-true]: <k> true => .K </k>
         <status> PROPERTY-EVALUATION-OR-FAIL => PROPERTY-SUCCESS </status>
    
    rule [property-false]: <k> false </k>
         <status> PROPERTY-EVALUATION-OR-FAIL => PROPERTY-FAIL </status>

    //exit
    rule [runner-exit]: <runner> .K </runner>
         <return-status> RETURN:Status => NO-RETURN </return-status>
         <status> PROPERTY-SUCCESS => RETURN </status> [priority(1000)]

endmodule

module PROJECT
    imports PROGRAM-LINKING
    imports DECLARATIONS
    imports TRAN-INIT

    //! Important! This will currently enter an infinite loop, krun only with --depth bound!
    imports TRAN-TRAN
    imports TRAN-ENV

    imports RUN-TRANSITION
endmodule