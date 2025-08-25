requires "project.k"

module PROJECT-SPEC
    imports PROJECT
    imports PROJECT-SYNTAX

    syntax Id ::= "$a" [token]
                | "a" [token]

    // claim <k> 
    //         var $a : integer = 0 
    //         trans { .Sequence } 
    //         init { .Sequence } 
    //         env { .Sequence } 
    //         prop { true } => .K 
    //     </k>
    //     // <state>
    //          <property> .Prop => true </property>
    //     //     <enum-definitions> .Map </enum-definitions>
    //          <variable-types> VARS => VARS [ $a <- integer ] </variable-types>
    //          <transition> .K => .Sequence ~> .K </transition>
    //         <init> .K => .K </init>
    //          <env> .K => .Sequence ~> .K </env>
    //          <variable-values> VALS => VALS [ $a <- 0/*?_:Int*/ ] </variable-values>
    //     // </state>
    //     // <linking>
    //         <linking-declarations> .K => .K </linking-declarations>
    //     // </linking>
    //      <runner> .K => .K </runner>
    //      <status> START => TRAN </status>
    //      <return-status> NO-RETURN => NO-RETURN </return-status>

    // claim <k> 
    //         var $a : integer = 0 
    //         trans { .Sequence } 
    //         init { .Sequence } 
    //         env { .Sequence } 
    //         prop { true } => .K 
    //     </k>
    //     <property> .Prop => ?_PROP_END </property>
    //     <enum-definitions> .Map => ?_ENUM_END </enum-definitions>
    //     <variable-types> _VARS => ?_VARS_END </variable-types>
    //     <transition> .K => ?_TRANS_END </transition>
    //     <init> .K => ?_INIT_END </init>
    //     <env> .K => ?_ENV_END </env>
    //     <variable-values> _VALS => ?_VALS_END </variable-values>
    //     <linking-declarations> .K => ?_DECL_END </linking-declarations>
    //     <runner> .K => ?_RUNNER_END </runner>
    //     <status> START => TRAN </status>
    //     <return-status> NO-RETURN => NO-RETURN </return-status>

    claim <k> 
            var a : integer = 0 
            trans { a := a + 1; } 
            init { .Sequence } 
            env { .Sequence } 
            prop { a < 10 } => .K 
        </k>
        <property> .Prop => ?_PROP_END </property>
        <enum-definitions> .Map => ?_ENUM_END </enum-definitions>
        <variable-types> _VARS => ?_VARS_END </variable-types>
        <transition> .K => ?_TRANS_END </transition>
        <init> .K => ?_INIT_END </init>
        <env> .K => ?_ENV_END </env>
        <variable-values> _VALS => ?_VALS_END </variable-values>
        <linking-declarations> .K => ?_DECL_END </linking-declarations>
        <runner> .K => ?_RUNNER_END </runner>
        <status> START => /*?STATUS*/PROPERTY-FAIL </status>
        <return-status> NO-RETURN => ?_NO_RETURN </return-status>
        //ensures notBool isFail( ?STATUS )
endmodule