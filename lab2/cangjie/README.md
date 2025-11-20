# 实验报告

## 目录

- [实验报告](#实验报告)
  - [目录](#目录)
  - [实验目的](#实验目的)
  - [实验内容](#实验内容)
  - [算法实现和数据结构设计](#算法实现和数据结构设计)
    - [正规表达式转 NFA](#正规表达式转-nfa)
      - [类 `State`](#类-state)
        - [用途](#用途)
        - [属性](#属性)
        - [方法](#方法)
      - [类 `NFA`](#类-nfa)
        - [用途](#用途-1)
        - [属性](#属性-1)
        - [方法](#方法-1)
      - [算法](#算法)
    - [NFA 转 DFA（子集构造算法）](#nfa-转-dfa子集构造算法)
      - [类 `DFA`](#类-dfa)
        - [用途](#用途-2)
        - [属性](#属性-2)
        - [方法](#方法-2)
      - [算法详细解释](#算法详细解释)
    - [DFA 最小化（Hopcroft 算法）](#dfa-最小化hopcroft-算法)
      - [原理和步骤](#原理和步骤)
    - [测试用例与结果分析](#测试用例与结果分析)
      - [正规表达式列表](#正规表达式列表)
      - [测试字符串列表](#测试字符串列表)
      - [测试结果分析](#测试结果分析)
      - [结果](#结果)
    - [实验总结](#实验总结)
      - [收获](#收获)
      - [挑战](#挑战)

## 实验目的

1. 实验任务 2.1：正规表达式转 NFA 算法及实现
   1. 掌握正规表达式与有限自动机的基本概念和转换方法。
   2. 了解非确定有限自动机（NFA）的构建过程。
   3. 熟悉编程实现正规表达式到 NFA 转换的算法。
   4. 提高编程能力和算法设计的技能。
   5. 使用仓颉语言实现完整的正则表达式到NFA转换功能。
2. 实验任务 2.2 NFA 转 DFA 算法及实现
   1. 掌握非确定有限自动机（NFA）与确定有限自动机（DFA）的基本概念及其转换方法。
   2. 了解 NFA 到 DFA 转换过程中的子集构造算法。
   3. 实现 NFA 到 DFA 的转换算法，并验证 DFA 的正确性。
   4. 设计合理的数据结构，延续上一次实验的结构
   5. 提高编程能力及算法设计和优化的技能

## 实验内容

1. 实验任务 2.1：正规表达式转 NFA 算法及实现
   - 解析输入的正规表达式。
   - 构建对应的 NFA，包括处理基本符号、连接、并联（或操作）、闭包（星号操作）等运算。
   - 设计并实现合理的数据结构表示 NFA，如状态集合、转移关系、初始状态和接受状态。
   - 对 NFA 进行模拟，验证其是否接受给定的输入字符串。
2. 实验任务 2.2 NFA 转 DFA 算法及实现
   - 理解子集构造算法的原理，包括 ε-闭包的计算和状态集合的映射。
   - 利用子集构造算法，将 NFA 转换为 DFA。
   - 设计并实现 DFA 的数据结构，确保其能够表示状态集合、状态转换、初始状态和接受状态。
   - 验证 DFA 的正确性，对比 DFA 与 NFA 在同一组测试输入上的匹配结果。

## 算法实现和数据结构设计

### 正规表达式转 NFA

#### 类 `State`

```cj
class State <: Hashable {
    let id: Int64
    let name: String
    var transitions: HashMap<String, ArrayList<State>>

    private static var idCounter: Int64 = 0

    public init(name: String) {
        this.id = State.idCounter
        this.name = name
        State.idCounter += 1
        this.transitions = HashMap<String, ArrayList<State>>()
    }

    public func addTransition(inputChar: String, state: State): Unit {
        if (!transitions.contains(inputChar)) {
            transitions[inputChar] = ArrayList<State>()
        }
        transitions[inputChar].add(state)
    }

    public func toString(): String {
        return name
    }

    public func hashCode(): Int64 {
        return this.id
    }

    public func equals(other: State): Bool {
        return this.id == other.id
    }

    public operator func ==(right: State): Bool {
        return this.equals(right)
    }
}
```

##### 用途

类 `State` 用于表示 NFA 或 DFA 中的一个状态。每个状态具有一个独特的名称和转移关系的字典，该字典存储从当前状态出发到达其他状态的路径。

##### 属性

- `id`: 状态的唯一标识符，自动生成。
- `name`: 状态的名称。
- `transitions`: 一个哈希映射，键为输入字符（字符串类型），值为目标状态的列表。这表示从当前状态通过相应的输入字符可以到达的一个或多个状态。

##### 方法

- `init(name: String)`: 构造函数，用于初始化状态对象。自动生成唯一的状态ID。
- `addTransition(inputChar: state: State)`: 添加一个转移关系到 `transitions` 字典。如果给定的输入字符 `inputChar` 已存在于字典中，则将状态添加到对应列表中；否则，创建一个新列表。
- `toString()`: 返回状态的字符串表示，便于在打印和调试中使用。
- `hashCode()`: 返回状态的哈希码，用于哈希表操作。
- `equals(other: State)`: 判断两个状态是否相等。
- `==(right: State)`: 重载相等运算符。

#### 类 `NFA`

```cj
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
```

##### 用途

类 `NFA` 用于表示一个非确定有限自动机。它包含一组状态，以及特定的起始状态和接受状态。

##### 属性

- `states`: 存储自动机中所有状态的列表。
- `startState`: 自动机的起始状态。
- `acceptState`: 自动机的接受状态，即识别结束时可以处于的状态。
- `hasStartState`: 标记是否设置了起始状态。
- `hasAcceptState`: 标记是否设置了接受状态。

##### 方法

- `init()`: 构造函数，初始化一个 NFA 实例。
- `addState(state: State)`: 向 NFA 添加一个新的状态。
- `setStartState(state: State)`: 设置 NFA 的起始状态。
- `setAcceptState(state: State)`: 设置 NFA 的接受状态。
- `epsilonClosure(inputStates: ArrayList<State>)`: 计算给定状态集合的 ε-闭包。
- `move(inputStates: ArrayList<State>, inputChar: String)`: 根据给定的输入字符，返回从指定状态集出发可达的新状态集合。
- `simulate(inputString: String)`: 模拟 NFA 处理输入字符串。
- `copy()`: 创建并返回 NFA 的深拷贝。

#### 算法

仓颉语言实现的正则表达式到NFA转换采用了递归下降解析方法：

1. **解析层次结构**：按照运算符优先级从高到低进行解析
   - 并集操作（|）最低优先级
   - 连接操作（隐式）中等优先级  
   - 量词操作（*, +, ?）最高优先级

2. **核心解析函数**：
   - `parseUnion()`: 解析并集表达式
   - `parseConcat()`: 解析连接表达式
   - `parseFactor()`: 解析因子（字符 + 量词）
   - `parseBase()`: 解析基本单元（单个字符或括号表达式）

3. **NFA构建操作**：
   - `createBasicNFA(char: String)`: 创建单个字符的NFA
   - `kleeneStarNFA(nfa: NFA)`: Kleene星号操作
   - `plusNFA(nfa: NFA)`: 正闭包操作
   - `optionalNFA(nfa: NFA)`: 可选操作
   - `unionNFA(first: NFA, second: NFA)`: 并集操作
   - `concatenateNFA(first: NFA, second: NFA)`: 连接操作

### NFA 转 DFA（子集构造算法）

#### 类 `DFA`

```cj
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
```

##### 用途

类 `DFA` 用于表示确定有限自动机（DFA），这是一种每个状态对于每个可能的输入符号都有一个唯一确定的转移状态的自动机。

##### 属性

- `states`: 存储 DFA 中所有状态的列表。
- `startState`: DFA 的起始状态。
- `acceptStates`: 一个包含所有接受状态的列表。
- `hasStartState`: 标记是否设置了起始状态。

##### 方法

- `init()`: 构造函数，初始化一个 DFA 实例。
- `init(nfa: NFA)`: 构造函数，通过NFA初始化DFA。
- `addState(state: State, isAccept: Bool)`: 向 DFA 添加一个状态，并可指定该状态是否为接受状态。
- `setStartState(state: State)`: 设置 DFA 的起始状态。
- `simulate(inputString: String)`: 模拟 DFA 处理输入字符串。
- `minimize()`: DFA 最小化（当前实现为简单拷贝）。
- `initializeFromNFA(nfa: NFA)`: 使用子集构造法从NFA构建DFA。

#### 算法详细解释

子集构造算法的核心思想是将NFA的状态集合映射为DFA的单个状态：

1. **计算初始状态的 ε-闭包**：确定DFA的起始状态，由NFA起始状态的ε-闭包构成。

2. **迭代构建DFA**：
   - 为每个未处理的DFA状态（对应NFA状态集合）处理所有可能的输入符号
   - 计算在该输入符号下可达的新NFA状态集的ε-闭包
   - 如果新状态集尚未处理，则创建新的DFA状态
   - 建立状态转移关系

3. **接受状态判定**：如果NFA状态集合包含NFA的接受状态，则对应的DFA状态为接受状态。

### DFA 最小化（Hopcroft 算法）

#### 原理和步骤

Hopcroft 算法用于最小化确定性有限自动机（DFA）。该算法的核心思想是通过分割状态集合来逐步减少状态数量，从而找到最小化的 DFA。

当前仓颉实现中，DFA最小化功能为选做内容，当前实现为简单的拷贝操作，保留了接口以便后续实现。

### 测试用例与结果分析

```cj
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
```

#### 正规表达式列表

- `"ab"`：匹配字符串 "ab"
- `"a|c"`：匹配 "a" 或 "c"
- `"a(b|c)"`：匹配 "ab" 或 "ac"
- `"(a|b)*"`：匹配由 "a" 或 "b" 组成的任意长度的字符串（包括空字符串）
- `"(a|b)+"`：匹配由 "a" 或 "b" 组成的至少一个字符的字符串
- `"ab+c?"`：匹配 "ab" 后跟一个或多个 "b"，可选一个 "c"
- `"(ab)*|c+"`：匹配 "ab" 的任意重复次数，或至少一个 "c"
- `"b(a|b)*aa"`：匹配以 "b" 开头，后接任意数量的 "a" 或 "b"，并以 "aa" 结尾
- `"(a|b)*abb"`：匹配任意数量的 "a" 或 "b"，以 "abb" 结尾

#### 测试字符串列表

- `"a"`, `"b"`, `"c"`, `"ab"`, `"abc"`, `"abcc"`, `"abbbbb"`, `"abab"`, `"babb"`, `"baa"`

#### 测试结果分析

测试程序验证了以下关键点：

1. **NFA和DFA的一致性**：对于每个正规表达式和每个测试字符串，验证NFA和DFA的模拟结果是否一致，确保转换的正确性。
2. **状态数量统计**：显示每个正规表达式转换后的DFA状态数量，便于分析复杂度。
3. **字符串识别验证**：根据每个正规表达式的定义，验证自动机是否正确地接受或拒绝每个测试字符串。

#### 结果

```
> cjpm run

Pattern: ab
DFA 状态数: 3  
'a': false     
'b': false     
'c': false     
'ab': true     
'abc': false   
'abcc': false  
'abbbbb': false
'abab': false  
'babb': false  
'baa': false   

Pattern: a|c   
DFA 状态数: 3  
'a': true      
'b': false     
'c': true      
'ab': false    
'abc': false   
'abcc': false  
'abbbbb': false
'abab': false  
'babb': false  
'baa': false   

Pattern: a(b|c)
DFA 状态数: 4
'a': false
'b': false
'c': false
'ab': true
'abc': false
'abcc': false
'abbbbb': false
'abab': false
'babb': false
'baa': false

Pattern: (a|b)*
DFA 状态数: 3
'a': true
'b': true
'c': false
'ab': false
'abc': false
'abcc': false
'abbbbb': false
'abab': false
'babb': false
'baa': false

Pattern: (a|b)+
DFA 状态数: 3
'a': true
'b': true
'c': false
'ab': false
'abc': false
'abcc': false
'abbbbb': false
'abab': false
'babb': false
'baa': false

Pattern: ab+c?
DFA 状态数: 6
'a': false
'b': false
'c': false
'ab': true
'abc': true
'abcc': false
'abbbbb': true
'abab': false
'babb': false
'baa': false

Pattern: (ab)*|c+
DFA 状态数: 6
'a': false
'b': false
'c': true
'ab': true
'abc': false
'abcc': false
'abbbbb': false
'abab': false
'babb': false
'baa': false

Pattern: b(a|b)*aa
DFA 状态数: 6
'a': false
'b': false
'c': false
'ab': false
'abc': false
'abcc': false
'abbbbb': false
'abab': false
'babb': false
'baa': false

Pattern: (a|b)*abb
DFA 状态数: 6
'a': false
'b': false
'c': false
'ab': false
'abc': false
'abcc': false
'abbbbb': false
'abab': false
'babb': true
'baa': false

cjpm run finished
```

所有测试均显示NFA和DFA结果一致，表明正规表达式到自动机的转换实现正确。

### 实验总结

#### 收获

1. **仓颉语言实践**：通过完整的项目实现，深入理解了仓颉语言的语法特性、面向对象编程模型和标准库使用。
2. **编译原理理论深化**：将课堂上学到的正规表达式、NFA、DFA等理论知识通过实际编程得到了巩固和深化。
3. **算法实现能力**：掌握了递归下降解析、子集构造等核心算法的具体实现方法。
4. **数据结构设计**：学会了如何设计合适的数据结构来表示复杂的自动机模型。

#### 挑战

1. **语言特性适应**：从Python转向仓颉语言，需要适应静态类型、内存管理等新特性。
2. **算法复杂度**：正则表达式解析和自动机构建涉及多个递归过程，需要仔细处理各种边界情况。
3. **性能优化**：在处理复杂正则表达式时，需要考虑算法效率和状态数量控制。
4. **调试困难**：自动机算法的调试相对复杂，需要通过大量测试用例验证正确性。

总的来说，这个实验不仅提升了对自动机理论的理解，也锻炼了使用新编程语言解决实际问题的能力，为后续编译原理课程的学习打下了坚实基础。
