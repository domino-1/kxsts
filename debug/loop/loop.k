module LOOP-SYNTAX
    imports INT

    syntax Program ::= Int

endmodule

module LOOP
    imports LOOP-SYNTAX
    imports INT
    imports BOOL

    configuration <k> $PGM:Program </k>
                  <iterator> 0 </iterator>
                  <isValid> true </isValid>

    rule <isValid> true => false </isValid>
         <iterator> 10 </iterator>

    rule <iterator> I:Int => I +Int 1 </iterator> [owise]
endmodule