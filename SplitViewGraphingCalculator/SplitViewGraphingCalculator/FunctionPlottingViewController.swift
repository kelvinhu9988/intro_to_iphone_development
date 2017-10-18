//
//  ViewController.swift
//  GraphingCalculator
//
//  Created by Daniel Hauagge on 9/14/16.
//  Copyright © 2016 Daniel Hauagge. All rights reserved.
//

import UIKit
import JavaScriptCore

class FunctionPlottingViewController: UIViewController, UITextFieldDelegate, FunctionPlottingViewDelegate {
    @IBOutlet weak var functionTextField: UITextField!
    @IBOutlet weak var functionPlottingView: FunctionPlottingView!

    var expressionFromSegue: String?
    var expressionIndexFromSegue: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        functionTextField.delegate = self
        functionPlottingView.delegate = self
        functionTextField.text = expressionFromSegue
        
        if let functionIndex = self.expressionIndexFromSegue {
            updateFunctionThumbnail(functionIndex)
        }
    }
    
    // MARK: - Text View Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        functionTextField.resignFirstResponder()
        functionPlottingView.setNeedsDisplay()
        if let expIndexFromSegue = self.expressionIndexFromSegue {
            FunctionsDB.sharedInstance.functions[expIndexFromSegue] = textField.text ?? ""
        }
        
        if let functionIndex = self.expressionIndexFromSegue {
            updateFunctionThumbnail(functionIndex)
        }
        
        return false
    }
    
    // MARK: - Function Plotting Delegate
    func functionToPlot() -> ((Double) -> Double)? {
        guard let expr = functionTextField.text else {
            return nil
        }
        if expr == "" {
            return nil
        }
        
        let jsSource = "sin = Math.sin; cos = Math.cos; pi = Math.PI; rand = Math.random; sqrt = Math.sqrt; tan = Math.tan; tanh = Math.tanh; round = Math.round; log = Math.log; var f = function(x) { return \( expr ); }"
        
        let context = JSContext()!
        context.evaluateScript(jsSource)
        context.exceptionHandler = {(ctx: JSContext?, value: JSValue?) in
            // type of String
            let stacktrace = value?.objectForKeyedSubscript("stack")?.toString()
            // type of Number
            let lineNumber = value?.objectForKeyedSubscript("line")
            // type of Number
            let column = value?.objectForKeyedSubscript("column")
            let moreInfo = "\tin method \(stacktrace!)\nJS ERROR:\tline number: \(lineNumber!), column: \(column!)"
            print("JS ERROR: \nJS ERROR:\(value!)\nJS ERROR:\(moreInfo)")
        }
        
        let funcJS = context.objectForKeyedSubscript("f")!
        if funcJS.isUndefined {
            return nil
        }
        
        let f : ((Double) -> (Double)) = {(x: Double) in
            let ret = funcJS.call(withArguments: [x])!
            let y : Double = ret.toDouble()
            return y
        }
        
        return f
    }
    
    func updateFunctionThumbnail(_ functionIndex: Int) {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 75, height: 75), true, 0.0)
        functionPlottingView.drawHierarchy(in: CGRect(x: 0, y: 0, width: 75, height: 75), afterScreenUpdates: true)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        FunctionsDB.sharedInstance.functionImages[functionIndex] = thumbnail!
        print(FunctionsDB.sharedInstance.functionImages)
        UIGraphicsEndImageContext()
    }
    
    // MARK: - Gestures
    @IBAction func panGestureTriggered(_ sender: UIPanGestureRecognizer) {
        functionPlottingView.setNeedsDisplay()
        print(sender.state)
        
        switch sender.state {
        case .changed:
            functionPlottingView.currTranslation = sender.translation(in: functionPlottingView)
        case .ended:
            let pnt = sender.translation(in: functionPlottingView)
            functionPlottingView.accumTranslation.x += pnt.x
            functionPlottingView.accumTranslation.y += pnt.y
            functionPlottingView.currTranslation = CGPoint.zero
        default: break
        }
    }
    
    @IBAction func tapGestureTriggered(_ sender: UITapGestureRecognizer) {
        functionPlottingView.crosshairLoc = sender.location(in: functionPlottingView)
        functionPlottingView.setNeedsDisplay()
        
        functionTextField.resignFirstResponder()
        functionPlottingView.setNeedsDisplay()
    }
    
    @IBAction func longTapGestureTriggered(_ sender: UILongPressGestureRecognizer) {
        functionPlottingView.crosshairLoc = nil
        functionPlottingView.setNeedsDisplay()
    }
    
    @IBAction func pinchGestureTriggered(_ sender: UIPinchGestureRecognizer) {
        print(sender.scale)
        functionPlottingView.currScale = sender.scale
        functionPlottingView.setNeedsDisplay()
        functionPlottingView.currScaleLocation = sender.location(in: functionPlottingView)
    }
    
}

