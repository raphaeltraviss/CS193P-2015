import Foundation

class CalculatorBrain: CustomStringConvertible {
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case ValueOperation(String, Double?)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, Int, (Double, Double) -> Double)
        case VariableOperation(String)
        
        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(operand)"
            case .UnaryOperation(let symbol, _):
                return symbol
            case .BinaryOperation(let symbol, _, _):
                return symbol
            case .ValueOperation(let symbol, _):
                return symbol
            case .VariableOperation(let symbol):
                return symbol
            }
        }
        
        var precedence: Int {
            switch self {
            case .BinaryOperation(_, let opPriority, _):
                return opPriority
            default:
                return 1
            }
        }
    }
    
    private var opStack = [Op]()
    
    var variableValues = [String:Double]()
    
    private var knownOps = [String: Op]()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }

        learnOp(Op.ValueOperation("π", M_PI))
        learnOp(Op.BinaryOperation("×", 1, *))
        learnOp(Op.BinaryOperation("÷", 1) { $1 / $0 })
        learnOp(Op.BinaryOperation("+", 0, +))
        learnOp(Op.BinaryOperation("−", 0) { $1 - $0 })
        learnOp(Op.UnaryOperation("±") { $0 * (-1) })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.VariableOperation("M"))
        
        // Restore state from prior launching, if it exists.
        if let savedProgram = defaults.objectForKey("program") {
            program = savedProgram
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? [String] {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    func saveProgram() {
        defaults.setObject(program, forKey: "program")
        defaults.synchronize()
    }
    
    private func describe(ops: [Op]) -> (result: String, remainingOps: [Op], opPrecedence: Int) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps, op.precedence)
            case let .ValueOperation(symbol, _):
                return ("\(symbol)", remainingOps, op.precedence)
            case let .UnaryOperation(symbol, _):
                let operandDescription = describe(remainingOps)
                return ("\(symbol)(\(operandDescription.result))", operandDescription.remainingOps, op.precedence)
            case let .BinaryOperation(symbol, _, _):
                // Group child descriptions in parenthesis if they are lower priority
                // than the current operation.
                let op1Description = describe(remainingOps)
                var operand1 = op1Description.result
                if op.precedence > op1Description.opPrecedence {
                    operand1 = "(\(operand1))"
                }
                
                let op2Description = describe(op1Description.remainingOps)
                var operand2 = op2Description.result
                if op.precedence > op2Description.opPrecedence {
                    operand2 = "(\(operand2))"
                }
                
                return ("\(operand2) \(symbol) \(operand1)", op2Description.remainingOps, op.precedence)
            case .VariableOperation(let variableSymbol):
                if let variableValue = variableValues[variableSymbol] {
                    return ("\(variableValue)", remainingOps, op.precedence)
                } else {
                    return ("?", remainingOps, op.precedence)
                }
            }
        }
        return (" ", ops, Int.max)
    }
    
    var description: String {
        var (descriptionResult, descriptionRemainder, _) = describe(opStack)
        var returnString = descriptionResult
        // Using a loop, since a computed property cannot be called rescursively.
        while !descriptionRemainder.isEmpty {
            (descriptionResult, descriptionRemainder, _) = describe(descriptionRemainder)
            returnString = "\(descriptionResult), \(returnString)"
        }
        return returnString
    }
    
    /**
     Evaluates an opstack recursively, eventually reaching a single result, or erroring.
     
     - Parameter ops: The opstack to evaluate.  This stack is a mix of operands and operations,
     and they are evaluated in a recursive tree.
     
     - Returns: A tuple that contains the result for this operation/operand evaluation,
     and a stack of remaining operand/operations to continue evaluating.
     */
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .ValueOperation(_, let value):
                return (value, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .VariableOperation(let variableSymbol):
                return (variableValues[variableSymbol], remainingOps)
            }
        }
        return (nil, ops)
    }

    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        return result
    }
    
    func reset() {
        opStack.removeAll()
        variableValues.removeAll()
        saveProgram()
    }
    
    func pushOperand(operand: Double) -> Double? {
        // Push the new operand onto the op stack.
        opStack.append(Op.Operand(operand))
        
        // Save the new program state.
        saveProgram()
        
        // Evaluate the new op stack.
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        // If the symbol is valid, push it onto the op stack.
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        
        // Save the new program state.
        saveProgram()
        
        // Evaluate the new op stack.
        return evaluate()
    }
}