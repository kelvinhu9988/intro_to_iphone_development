//
//  ViewController.swift
//  Calculator
//
//  Created by Kelvin Hu on 9/4/17.
//  Copyright © 2017 Kelvin Hu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var numberOnScreen: Double = 0;
    var previousNumber: Double = 0;
    var performingMath = false;
    var operation = 0;
    
    @IBOutlet weak var label: UILabel!
    
    @IBAction func numbers(_ sender: UIButton)
    {
        
        if performingMath == true
        {
            if sender.tag == 10
            {
                label.text = "0"
            }
            else
            {
                label.text = String(sender.tag)
            }
            numberOnScreen = Double(label.text!)!
            performingMath = false
        }
        else
        {
            if sender.tag == 10
            {
                label.text = label.text! + "0"
            }
            else
            {
                label.text = label.text! + String(sender.tag)
            }
            numberOnScreen = Double(label.text!)!
        }
        
        
        
    }
    
    @IBAction func buttons(_ sender: UIButton) {
        if label.text != "" && sender.tag != 11 && sender.tag != 16
        {
            
            previousNumber = Double(label.text!)!
            operation = sender.tag
            
            if sender.tag == 12 //Divide
            {
                label.text = "÷"
            }
            else if sender.tag == 13 //Multiply
            {
                label.text = "×"
            }
            else if sender.tag == 14 //Minus
            {
                label.text = "–"
            }
            else if sender.tag == 15 //Plus
            {
                label.text = "+"
            }
            
            performingMath = true
        }
        else if sender.tag == 16
        {
            if operation == 12
            {
                let result: Double = previousNumber / numberOnScreen
                if isDoubleInteger(result)
                {
                    label.text = String(Int(result))
                }
                else
                {
                    label.text = String(result)
                }
            }
            else if operation == 13
            {
                let result: Double = previousNumber * numberOnScreen
                if isDoubleInteger(result)
                {
                    label.text = String(Int(result))
                }
                else
                {
                    label.text = String(result)
                }
            }
            else if operation == 14
            {
                let result: Double = previousNumber - numberOnScreen
                if isDoubleInteger(result)
                {
                    label.text = String(Int(result))
                }
                else
                {
                    label.text = String(result)
                }
            }
            else if operation == 15
            {
                let result: Double = previousNumber + numberOnScreen
                if isDoubleInteger(result)
                {
                    label.text = String(Int(result))
                }
                else
                {
                    label.text = String(result)
                }
            }
        }
        else if sender.tag == 11
        {
            label.text = ""
            previousNumber = 0
            numberOnScreen = 0
            operation = 0
        }
    }
    
    func isDoubleInteger(_ number: Double) -> Bool {
        let isInteger = floor(number) == number
        return isInteger
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

