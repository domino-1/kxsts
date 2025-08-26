requires "inKeys.k"

module INKEYS-SPEC
    imports INKEYS
    imports BOOL
    imports MAP
    imports SET

    // rule { ITEM in_keys ( M:Map ) #Equals true } => { ITEM in keys( M ) #Equals true } [simplification]
    
    // rule { ITEM in_keys ( M:Map ) #Equals true } => { true #Equals true }
    //      requires ITEM in_keys ( M ) [simplification]

    // This works to a degree - maps with only a single item, or multi item maps in a certain order work
    rule { ITEM in_keys ( _M:Map [ ITEM <- _VALUE ] ) #Equals true } => { true #Equals true } [simplification]

    // rule M:Map => keys( M ) [simplification]

    claim <k> start => done </k>
          <store> _MAP => ?_MAP_END </store>
          <target> a </target>

    claim <k> start => done </k>
          <store> _MAP => ?_MAP_END </store>
          <target> b </target>


endmodule