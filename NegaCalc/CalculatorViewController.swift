//
//  ViewController.swift
//  NegaCalc
//
//  Created by Raphael on 7/26/15.
//  Copyright (c) 2015 Skyleaf Design LLC. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var register: UILabel!
    
    var userIsInTheMiddleOfTypingANumber: Bool = false
    
    var brain = CalculatorBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        register.text = "\(brain)"
        if let evaluationResult = brain.evaluate() {
            register.text! += " ="
            displayValue = evaluationResult
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            // Allow only one decimal point.
            if !(display.text!.rangeOfString(".") != nil && digit == ".") {
                display.text = display.text! + digit
            }
        }
        else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        register.text = "\(brain)"
        print("Digit = \(digit)")
    }
    

    @IBAction func removeDigit() {
        if userIsInTheMiddleOfTypingANumber {
            display.text = String((display.text!).characters.dropLast())
            if (display.text!).characters.count == 0 {
                display.text = "0"
                userIsInTheMiddleOfTypingANumber = false
            }
        }
    }
    
    @IBAction func clear() {
        brain.reset()
        userIsInTheMiddleOfTypingANumber = false
        displayValue = nil
        register.text = "0"
    }
    
    @IBAction func changeSign(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if let minusSignRange = display.text!.rangeOfString("-")   {
                display.text!.removeAtIndex(minusSignRange.startIndex)
            } else {
                display.text = "-" + display.text!
            }
        } else {
            operate(sender)
            print(sender.currentTitle)
        }
    }
 
    @IBAction func setVariable() {
        if userIsInTheMiddleOfTypingANumber {
            brain.variableValues["M"] = displayValue;
            print("\(brain.variableValues)")
            userIsInTheMiddleOfTypingANumber = false;
            displayValue = brain.evaluate()
            register.text = "\(brain) ="
        }
    }
    
    /**
     An internal numeric value derived from the numbers a user has typed into the keypad.
    */
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            if let number = newValue {
                display.text = "\(number)"
            } else {
                display.text = "0"
            }
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if displayValue != nil {
            if let result = brain.pushOperand(displayValue!) {
                displayValue = result
            } else {
                displayValue = nil
            }
        } else {
            displayValue = nil
        }
        register.text = "\(brain) ="
    }
    
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        register.text = "\(brain) ="
    }
    
    // Use prepareForSegue to load the program into the graphViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let graphViewNavigationController = segue.destinationViewController as? UINavigationController {
                if let graphViewController = graphViewNavigationController.visibleViewController as? GraphViewController {
                    graphViewController.title = brain.description
                    graphViewController.program = brain.program
                    
                }
            }
        }
    }
}

