module ENSURES-SYNTAX
    imports BOOL
    imports INT

    syntax Program ::= "something" | Bool | Status | Int

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
                    | ".Status"

    syntax Bool ::= isFail( Status ) [function]

endmodule

module ENSURES
    imports ENSURES-SYNTAX
    imports INT

    configuration <k> $PGM:Program </k>
                  <status> .Status </status>
                  <step> 0 </step>
                  <isValid> true </isValid>

    // rule <status> .Status => PROPERTY-SUCCESS </status>
    //      <step> 0 => 1 </step>

    // rule <status> PROPERTY-SUCCESS => PROPERTY-FAIL </status>
    //      <step> 1 => 2 </step>

    rule <k> 10 => 11 </k>
         <isValid> true => false </isValid>

    rule <k> INT => INT +Int 1 </k> [owise]

    rule isFail( PROPERTY-FAIL ) => true
    rule isFail( _ ) => false [owise]

    // rule <k> something => isFail( STATUS ) </k>
    //      <status> STATUS </status>
    //      <step> 1 </step>
endmodule