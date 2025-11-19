from lab2 import DFA, Regex


def replace_char_to_fw(text: str) -> str:
    chr_table = {
        "/": "／",
        "*": "＊",
        ":": "：",
        "\\": "＼",
        ">": "＞",
        "<": "＜",
        "|": "｜",
        "?": "？",
        '"': "＂",
    }
    for k, v in chr_table.items():
        text = text.replace(k, v)
    return text


def main():
    patterns = [
        "ab",
        "a|c",
        "a(b|c)",
        "(a|b)*",
        "(a|b)+",
        "ab+c?",
        "(ab)*|c+",
        "b(a|b)*aa",
        "(a|b)*abb",
    ]
    strings = ["ab", "abc", "abcc", "c", "abbbbb", "abab", "bababababaaa"]

    for pattern in patterns:
        regex = Regex(pattern)
        print(f"\nTesting pattern: {regex.pattern}")
        nfa = regex.to_nfa()
        dfa = DFA(nfa)
        mini_dfa = dfa.minimize()
        nfa.visualize("result/nfa_" + replace_char_to_fw(pattern))
        dfa.visualize("result/dfa_" + replace_char_to_fw(pattern))
        mini_dfa.visualize("result/dfa_minimize_" + replace_char_to_fw(pattern))
        for string in strings:
            nfa_result = nfa.simulate(string)
            dfa_result = dfa.simulate(string)
            mini_dfa_result = mini_dfa.simulate(string)
            assert nfa_result == dfa_result
            assert mini_dfa_result == dfa_result
            if nfa_result:
                print(f"Matched: {string}")
            else:
                print(f"Unmatched: {string}")


if __name__ == "__main__":
    main()
