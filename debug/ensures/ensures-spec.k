requires "ensures.k"

module ENSURES-SPEC

    imports ENSURES

    // claim <k> something => something </k>
    //       <status> .Status => ?STATUSRESULT </status>
    //       <step> 0 => 2 </step>
    //       ensures notBool isFail( ?STATUSRESULT )
    //       //ensures (?BOOLRESULT ==Bool true) //orBool (?BOOLRESULT ==Bool false)

    claim <status> .Status </status>
          <step> 0 </step>
          <k> 1 => ?_INT </k>
          <isValid> true </isValid>
          //ensures ?INT <Int 10
 
endmodule