requires "loop.k"

module LOOP-SPEC
    imports LOOP

    //Top - TrivialClaim
    claim <k> 10 </k>
          <iterator> 0 => ?_INT </iterator>
          <isValid> true </isValid>

    //Top - TrivialClaim
    claim <k> 10 </k>
          <iterator> 0 => ?_INT </iterator>
          <isValid> false </isValid>
    
    //Top
    claim <k> 10 </k>
          <iterator> 0 => 10 </iterator>
          <isValid> true </isValid>

    //Top
    claim <k> 10 </k>
          <iterator> 0 => 10 </iterator>
          <isValid> false </isValid>

    //Top
    claim <k> 10 </k>
          <iterator> 0 => 11 </iterator>
          <isValid> false </isValid>

    //Top [Note: ???]
    claim <k> 10 </k>
          <iterator> 0 => 9 </iterator>
          <isValid> false </isValid>

    //Doesn't stop
    // claim <k> 10 </k>
    //       <iterator> 0 => 11 </iterator>
    //       <isValid> true </isValid>

endmodule

