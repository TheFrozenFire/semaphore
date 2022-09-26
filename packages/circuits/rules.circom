pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";

template Rules(nAttributes) {
    signal input attributes[nAttributes];
        
    var nRules = 2;
    
    component ruleset[nAttributes][nRules];
    component rulesetEnables[nAttributes][nRules];
    for(var i = 0; i < nAttributes; i++) {
        // Use only 248 bits for rule values, save remaining in-field bits for flagging
        // Equality can be tested by checking `(attribute < expected + 1) & (attribute > expected - 1)`
        // Inequality can be tested by checking `(attribute < expected) & (attribute > expected)`
        ruleset[i][0] = LessThan(248);
        ruleset[i][1] = GreaterThan(248);
        
        for(var j = 0; j < nRules; j++) {
            rulesetEnables[i][j] = ForceEqualIfEnabled();
        }
    }

    signal input attributeRuleInputs[nAttributes][nRules];
    for(var i = 0; i < nAttributes; i++) {
        // Comparator will only use 248 bits
        ruleset[i][0].in[0] <== attributeRuleInputs[i][0];
        
        for(var j = 0; j < nRules; j++) {
            // Sloppy check for any of the bits gt 248 being raised, meaning enabled
            rulesetEnables[i][j].enabled <== attributeRuleInputs[i][j] % (2**248);
        }
    }
}
