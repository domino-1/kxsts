module INKEYS-SYNTAX
    imports ID

    syntax Program ::= "start" | "update" | "update2" | "done"
    syntax Id ::= "a" [token]
                | "b" [token]

endmodule

module INKEYS
    imports INKEYS-SYNTAX
    imports MAP
    imports ID
    imports INT

    configuration <k> $PGM:Program </k>
                  <store> .Map </store>
                  <target> a </target>

    rule <k> start => update </k>
         <store> MAP => MAP [ b <- 0 ] </store>

    rule <k> update => update2 </k>
         <store> MAP => MAP [ a <- 0 ] </store>

    rule <k> update2 => done </k>
         <target> TARGET </target>
         <store> MAP => MAP [ TARGET <- 1 ] </store>
         //requires TARGET in_keys ( MAP )
endmodule