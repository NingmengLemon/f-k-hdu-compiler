package principle_of_compilers_lab2

import std.collection.*

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

    public static func getIdCounter(): Int64 {
        return idCounter
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