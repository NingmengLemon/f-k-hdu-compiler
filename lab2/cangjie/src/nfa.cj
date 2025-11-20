package principle_of_compilers_lab2

import std.collection.*

class NFA {
    var states: ArrayList<State>
    var startState: State
    var acceptState: State
    var hasStartState: Bool
    var hasAcceptState: Bool

    public init() {
        this.states = ArrayList<State>()
        this.startState = State("")
        this.acceptState = State("")
        this.hasStartState = false
        this.hasAcceptState = false
    }

    public func addState(state: State): Unit {
        states.add(state)
    }

    public func setStartState(state: State): Unit {
        this.startState = state
        this.hasStartState = true
    }

    public func setAcceptState(state: State): Unit {
        this.acceptState = state
        this.hasAcceptState = true
    }

    public func epsilonClosure(inputStates: ArrayList<State>): ArrayList<State> {
        var closure = ArrayList<State>()
        var workList = ArrayList<State>()
        
        // 初始添加所有输入状态
        for (state in inputStates) {
            closure.add(state)
            workList.add(state)
        }
        
        // 处理工作列表中的状态
        while (workList.size > 0) {
            let currentState = workList[workList.size - 1]
            workList.remove(workList.size - 1..workList.size)
            
            if (currentState.transitions.contains("ε")) {
                let epsilonStates = currentState.transitions["ε"]
                for (nextState in epsilonStates) {
                    // 检查状态是否已经在闭包中
                    var alreadyInClosure = false
                    for (existingState in closure) {
                        if (existingState == nextState) {
                            alreadyInClosure = true
                            break
                        }
                    }
                    
                    if (!alreadyInClosure) {
                        closure.add(nextState)
                        workList.add(nextState)
                    }
                }
            }
        }
        
        return closure
    }

    public func move(inputStates: ArrayList<State>, inputChar: String): ArrayList<State> {
        var nextStates = ArrayList<State>()
        for (state in inputStates) {
            if (state.transitions.contains(inputChar)) {
                let charStates = state.transitions[inputChar]
                for (nextState in charStates) {
                    nextStates.add(nextState)
                }
            }
        }
        return nextStates
    }

    public func simulate(inputString: String): Bool {
        if (!this.hasStartState) {
            return false
        }
        var currentStates = ArrayList<State>()
        currentStates.add(this.startState)
        currentStates = epsilonClosure(currentStates)
        
        for (i in 0..inputString.size) {
            if (i >= inputString.size) {
                break
            }
            let char = inputString[i..i+1]
            var nextStates = move(currentStates, char)
            nextStates = epsilonClosure(nextStates)
            currentStates = nextStates
        }
        
        if (!this.hasAcceptState) {
            return false
        }
        for (state in currentStates) {
            if (state == this.acceptState) {
                return true
            }
        }
        return false
    }

    public func copy(): NFA {
        var newNfa = NFA()
        var stateMap = HashMap<String, State>()
        
        // 首先创建所有新状态
        for (state in this.states) {
            let newState = State(state.toString())
            stateMap[state.toString()] = newState
            newNfa.addState(newState)
        }
        
        // 复制转换关系
        for (state in this.states) {
            let newState = stateMap[state.toString()]
            for (entry in state.transitions) {
                let char = entry[0]
                let targets = entry[1]
                for (target in targets) {
                    if (stateMap.contains(target.toString())) {
                        let newTarget = stateMap[target.toString()]
                        newState.addTransition(char, newTarget)
                    }
                }
            }
        }
        
        if (this.hasStartState) {
            newNfa.setStartState(stateMap[this.startState.toString()])
        }
        if (this.hasAcceptState) {
            newNfa.setAcceptState(stateMap[this.acceptState.toString()])
        }
        return newNfa
    }
}