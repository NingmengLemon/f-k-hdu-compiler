package principle_of_compilers_lab2

import std.collection.*

main(): Int64 {
    let testPatterns = ["ab", "a|c", "a(b|c)", "(a|b)*", "(a|b)+", "ab+c?", "(ab)*|c+", "b(a|b)*aa", "(a|b)*abb"]
    let testStrings = ["a", "b", "c", "ab", "abc", "abcc", "abbbbb", "abab", "babb", "baa"]

    for (pattern in testPatterns) {
        println("\nPattern: ${pattern}")
        let regex = Regex(pattern)
        let nfa = regex.toNFA()
        let dfa = DFA(nfa)

        println("DFA 状态数: ${dfa.states.size}")

        for (str in testStrings) {
            let nfaResult = nfa.simulate(str)
            let dfaResult = dfa.simulate(str)

            // 检查NFA和DFA结果是否一致
            if (nfaResult == dfaResult) {
                println("'${str}': ${nfaResult}")
            } else {
                println("!! '${str}': NFA 和 DFA 结果不一致")
            }
        }
    }

    return 0
}
