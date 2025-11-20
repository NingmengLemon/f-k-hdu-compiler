package principle_of_compilers_lab2

class Regex {
    let pattern: String

    public init(pattern: String) {
        this.pattern = pattern
    }

    public func toNFA(): NFA {
        if (pattern.size == 0) {
            return createEpsilonNFA()
        }

        // 使用简单的方法：先处理并集，再处理连接
        return parseUnion()
    }

    // 解析并集表达式 (最高优先级)
    private func parseUnion(): NFA {
        // 先解析第一个项
        var left = parseConcat()

        // 检查是否有更多的并集操作
        var remainingPattern = getRemainingPatternAfterConcat()

        while (remainingPattern.size > 0 && remainingPattern[0..1] == "|") {
            // 跳过 |
            let nextPattern = remainingPattern[1..remainingPattern.size]
            let right = parseConcatFrom(nextPattern)
            left = unionNFA(left, right)
            remainingPattern = getRemainingPatternAfterConcatFrom(nextPattern)
        }

        return left
    }

    // 解析连接表达式
    private func parseConcat(): NFA {
        return parseConcatFrom(pattern)
    }

    private func parseConcatFrom(expr: String): NFA {
        if (expr.size == 0) {
            return createEpsilonNFA()
        }

        var left = parseFactor(expr)

        // 获取剩余部分
        var consumed = getFactorLength(expr)
        var remaining = expr[consumed..expr.size]

        while (remaining.size > 0) {
            let nextChar = remaining[0..1]
            if (nextChar == "|" || nextChar == ")") {
                break
            }

            let right = parseFactor(remaining)
            left = concatenateNFA(left, right)
            consumed = getFactorLength(remaining)
            remaining = remaining[consumed..remaining.size]
        }

        return left
    }

    // 解析因子（字符 + 量词）
    private func parseFactor(expr: String): NFA {
        if (expr.size == 0) {
            return createEpsilonNFA()
        }

        let base = parseBase(expr)

        // 检查是否有量词
        if (expr.size > 1) {
            let quantifier = expr[1..2]
            match (quantifier) {
                case "*" => return kleeneStarNFA(base)
                case "+" => return plusNFA(base)
                case "?" => return optionalNFA(base)
                case _ => return base
            }
        }

        return base
    }

    // 解析基本单元
    private func parseBase(expr: String): NFA {
        if (expr.size == 0) {
            return createEpsilonNFA()
        }

        let firstChar = expr[0..1]

        if (firstChar == "(") {
            // 找到匹配的右括号
            var parenCount = 1
            var endPos = 1

            while (endPos < expr.size && parenCount > 0) {
                let char = expr[endPos..endPos + 1]
                if (char == "(") {
                    parenCount += 1
                } else if (char == ")") {
                    parenCount -= 1
                }
                endPos += 1
            }

            if (parenCount == 0) {
                let innerExpr = expr[1..endPos - 1]
                return parseUnionFrom(innerExpr)
            } else {
                return createBasicNFA(firstChar)
            }
        } else {
            return createBasicNFA(firstChar)
        }
    }

    // 辅助函数：获取因子长度
    private func getFactorLength(expr: String): Int64 {
        if (expr.size == 0) {
            return 0
        }

        let firstChar = expr[0..1]

        if (firstChar == "(") {
            // 找到匹配的右括号
            var parenCount = 1
            var endPos = 1

            while (endPos < expr.size && parenCount > 0) {
                let char = expr[endPos..endPos + 1]
                if (char == "(") {
                    parenCount += 1
                } else if (char == ")") {
                    parenCount -= 1
                }
                endPos += 1
            }

            // 检查是否有量词
            if (endPos < expr.size) {
                let nextChar = expr[endPos..endPos + 1]
                if (nextChar == "*" || nextChar == "+" || nextChar == "?") {
                    return endPos + 1
                }
            }
            return endPos
        } else {
            // 单个字符，检查是否有量词
            if (expr.size > 1) {
                let nextChar = expr[1..2]
                if (nextChar == "*" || nextChar == "+" || nextChar == "?") {
                    return 2
                }
            }
            return 1
        }
    }

    // 辅助函数：获取剩余模式
    private func getRemainingPatternAfterConcat(): String {
        return getRemainingPatternAfterConcatFrom(pattern)
    }

    private func getRemainingPatternAfterConcatFrom(expr: String): String {
        let consumed = getFactorLength(expr)
        return expr[consumed..expr.size]
    }

    // 从指定表达式解析并集
    private func parseUnionFrom(expr: String): NFA {
        if (expr.size == 0) {
            return createEpsilonNFA()
        }

        var left = parseConcatFrom(expr)

        var remainingPattern = getRemainingPatternAfterConcatFrom(expr)

        while (remainingPattern.size > 0 && remainingPattern[0..1] == "|") {
            let nextPattern = remainingPattern[1..remainingPattern.size]
            let right = parseConcatFrom(nextPattern)
            left = unionNFA(left, right)
            remainingPattern = getRemainingPatternAfterConcatFrom(nextPattern)
        }

        return left
    }

    // 创建基本NFA（单个字符）
    private func createBasicNFA(char: String): NFA {
        let startState = State("S" + State.getIdCounter().toString())
        let acceptState = State("S" + State.getIdCounter().toString())
        startState.addTransition(char, acceptState)

        let nfa = NFA()
        nfa.addState(startState)
        nfa.addState(acceptState)
        nfa.setStartState(startState)
        nfa.setAcceptState(acceptState)
        return nfa
    }

    // 创建epsilon NFA
    private func createEpsilonNFA(): NFA {
        let startState = State("S" + State.getIdCounter().toString())
        let acceptState = State("S" + State.getIdCounter().toString())
        startState.addTransition("ε", acceptState)

        let nfa = NFA()
        nfa.addState(startState)
        nfa.addState(acceptState)
        nfa.setStartState(startState)
        nfa.setAcceptState(acceptState)
        return nfa
    }

    // Kleene Star操作
    private func kleeneStarNFA(nfa: NFA): NFA {
        if (!nfa.hasStartState || !nfa.hasAcceptState) {
            return createEpsilonNFA()
        }

        let newStart = State("S" + State.getIdCounter().toString())
        let newAccept = State("S" + State.getIdCounter().toString())

        // 新的开始状态到原开始状态
        newStart.addTransition("ε", nfa.startState)
        // 新的开始状态到新的接受状态（空匹配）
        newStart.addTransition("ε", newAccept)
        // 原接受状态到原开始状态（循环）
        nfa.acceptState.addTransition("ε", nfa.startState)
        // 原接受状态到新的接受状态
        nfa.acceptState.addTransition("ε", newAccept)

        let result = NFA()
        result.addState(newStart)
        result.addState(newAccept)
        for (state in nfa.states) {
            result.addState(state)
        }

        result.setStartState(newStart)
        result.setAcceptState(newAccept)
        return result
    }

    // Plus操作
    private func plusNFA(nfa: NFA): NFA {
        // a+ = aa*
        let starNFA = kleeneStarNFA(nfa)
        return concatenateNFA(nfa.copy(), starNFA)
    }

    // Optional操作
    private func optionalNFA(nfa: NFA): NFA {
        // a? = a|ε
        let epsilonNFA = createEpsilonNFA()
        return unionNFA(nfa, epsilonNFA)
    }

    // 并集操作
    private func unionNFA(first: NFA, second: NFA): NFA {
        if (!first.hasStartState || !first.hasAcceptState) {
            return second
        }
        if (!second.hasStartState || !second.hasAcceptState) {
            return first
        }

        let newStart = State("S" + State.getIdCounter().toString())
        let newAccept = State("S" + State.getIdCounter().toString())

        // 新的开始状态到两个NFA的开始状态
        newStart.addTransition("ε", first.startState)
        newStart.addTransition("ε", second.startState)
        // 两个NFA的接受状态到新的接受状态
        first.acceptState.addTransition("ε", newAccept)
        second.acceptState.addTransition("ε", newAccept)

        let result = NFA()
        result.addState(newStart)
        result.addState(newAccept)
        for (state in first.states) {
            result.addState(state)
        }
        for (state in second.states) {
            result.addState(state)
        }

        result.setStartState(newStart)
        result.setAcceptState(newAccept)
        return result
    }

    // 连接操作
    private func concatenateNFA(first: NFA, second: NFA): NFA {
        if (!first.hasStartState || !first.hasAcceptState || !second.hasStartState || !second.hasAcceptState) {
            return createEpsilonNFA()
        }

        // 连接第一个NFA的接受状态到第二个NFA的开始状态
        first.acceptState.addTransition("ε", second.startState)

        // 合并状态
        let result = NFA()
        for (state in first.states) {
            result.addState(state)
        }
        for (state in second.states) {
            result.addState(state)
        }

        result.setStartState(first.startState)
        result.setAcceptState(second.acceptState)
        return result
    }
}
