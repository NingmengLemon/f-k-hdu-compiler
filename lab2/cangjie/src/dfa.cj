package principle_of_compilers_lab2

import std.collection.*

class DFA {
    var states: ArrayList<State>
    var startState: State
    var acceptStates: ArrayList<State>
    var hasStartState: Bool

    public init() {
        this.states = ArrayList<State>()
        this.startState = State("")
        this.acceptStates = ArrayList<State>()
        this.hasStartState = false
    }

    public init(nfa: NFA) {
        this.states = ArrayList<State>()
        this.startState = State("")
        this.acceptStates = ArrayList<State>()
        this.hasStartState = false
        initializeFromNFA(nfa)
    }

    public func addState(state: State, isAccept: Bool): Unit {
        states.add(state)
        if (isAccept) {
            acceptStates.add(state)
        }
    }

    public func setStartState(state: State): Unit {
        this.startState = state
        this.hasStartState = true
    }

    public func simulate(inputString: String): Bool {
        if (!this.hasStartState) {
            return false
        }
        var currentState = this.startState

        for (i in 0..inputString.size) {
            if (i >= inputString.size) {
                break
            }
            let char = inputString[i..i + 1]
            if (currentState.transitions.contains(char)) {
                let nextStates = currentState.transitions[char]
                if (nextStates.size > 0) {
                    currentState = nextStates[0]
                } else {
                    return false
                }
            } else {
                return false
            }
        }

        for (state in acceptStates) {
            if (state == currentState) {
                return true
            }
        }
        return false
    }

    public func minimize(): DFA {
        // 最小化选做
        return this.copy()
    }

    public func copy(): DFA {
        var newDFA = DFA()

        for (state in this.states) {
            let newState = State(state.toString())
            var isAccept = false
            for (acceptState in this.acceptStates) {
                if (acceptState == state) {
                    isAccept = true
                    break
                }
            }
            newDFA.addState(newState, isAccept)
        }

        if (this.hasStartState) {
            newDFA.setStartState(State(this.startState.toString()))
        }

        return newDFA
    }

    public func initializeFromNFA(nfa: NFA): Unit {
        if (!nfa.hasStartState) {
            return
        }

        let initialClosure = nfa.epsilonClosure(ArrayList<State>([nfa.startState]))
        let startState = State("q0")

        // 检查初始闭包是否包含接受状态
        var isStartAccept = false
        for (state in initialClosure) {
            if (state == nfa.acceptState) {
                isStartAccept = true
                break
            }
        }

        this.addState(startState, isStartAccept)
        this.setStartState(startState)

        var unmarked = ArrayList<(State, ArrayList<State>)>()
        var marked = HashMap<String, State>()

        let initialKey = getStateSetKey(initialClosure)
        marked[initialKey] = startState
        unmarked.add((startState, initialClosure))

        while (unmarked.size > 0) {
            let lastIndex = unmarked.size - 1
            let (currentDFAState, currentNFAStates) = unmarked[lastIndex]
            unmarked.remove(lastIndex..lastIndex + 1)

            // 获取所有可能的输入符号
            var symbols = ArrayList<String>()
            for (state in currentNFAStates) {
                for (entry in state.transitions) {
                    let char = entry[0]
                    if (char != "ε") {
                        var found = false
                        for (existingSymbol in symbols) {
                            if (existingSymbol == char) {
                                found = true
                                break
                            }
                        }
                        if (!found) {
                            symbols.add(char)
                        }
                    }
                }
            }

            for (symbol in symbols) {
                let newNFAStates = nfa.epsilonClosure(nfa.move(currentNFAStates, symbol))
                let newKey = getStateSetKey(newNFAStates)

                if (!marked.contains(newKey)) {
                    let newDFAState = State("q" + states.size.toString())
                    var isAccept = false
                    for (s in newNFAStates) {
                        if (s == nfa.acceptState) {
                            isAccept = true
                            break
                        }
                    }
                    this.addState(newDFAState, isAccept)
                    marked[newKey] = newDFAState
                    unmarked.add((newDFAState, newNFAStates))
                }

                let targetState = marked[newKey]
                currentDFAState.addTransition(symbol, targetState)
            }
        }
    }

    private func getStateSetKey(states: ArrayList<State>): String {
        var key = ""
        for (state in states) {
            key += state.toString() + ","
        }
        return key
    }
}
