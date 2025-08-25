module MAP-DEBUG-SYNTAX
    imports INT

    syntax Program ::= "something" | Int

endmodule

module MAP-DEBUG
    imports MAP-DEBUG-SYNTAX
    imports MAP
    imports INT

    configuration <k> $PGM:Program </k>
                  <map> .Map </map>
                  <step> 0 </step>

    rule <map> MAP => MAP [ 0 <- 0 ] </map>
         <step> 0 => 1 </step>
    rule <map> MAP => MAP [ 1 <- 1 ] </map>
         <step> 1 => 2 </step>
    rule <map> MAP => MAP [ 2 <- 2 ] </map>
         <step> 2 => 3 </step>

    rule <map>... 1 |-> VALUE ...</map>
         <k> something => VALUE </k>
         <step> 3 => 4 </step>
endmodule