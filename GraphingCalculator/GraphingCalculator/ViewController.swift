//
//  ViewController.swift
//  GraphingCalculator
//
//  Created by Kelvin Hu on 9/9/17.
//  Copyright © 2017 Kelvin Hu. All rights reserved.
//

import UIKit
import JavaScriptCore

class ViewController: UIViewController, UITextFieldDelegate, FunctionPlottingViewDelegate {
    
    @IBOutlet weak var exprTextField: UITextField!
    @IBOutlet weak var plotView: FunctionPlottingView!
    @IBOutlet weak var crossingPointLabel: UILabel!
    
    var crosshairLoc: CGPoint?
    var panningVector: CGPoint?
    var pintchScale: CGFloat?
    var dismissCrosshair: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exprTextField.delegate = self
        plotView.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("called return")
        exprTextField.resignFirstResponder() // <- dismisses the keyboard
        plotView.setNeedsDisplay() // <- tells the plot view it needs to redraw
        return false
    }
    
    func getFunctionToPlot() -> ((Double) -> Double)? {
        let expr: String = exprTextField.text!.lowercased();
        
        if expr == "" {
            return nil
        }
        
        // JavaScript code we will execute
        let jsSrc = "sin = Math.sin; cos = Math.cos; tan = Math.tan; log = Math.log; var f = function(x) { return \(expr); };"
        
        // Create code and execute script, this will create the function inside the context
        let jsCtx = JSContext()!
        jsCtx.evaluateScript(jsSrc)
        
        // Get a reference to the function in the context
        guard let f = jsCtx.objectForKeyedSubscript("f") else {
            return nil
        }
        // If user inputs garbage and we can't evaluate, then exit
        if f.isUndefined {
            return nil
        }
        
        return { (x: Double) in return f.call(withArguments: [x])!.toDouble() }
    }
    
    func getFunctionDerivative() -> ((Double) -> Double)? {
        let expr: String = exprTextField.text!.lowercased();
        
        if expr == "" {
            return nil
        }
        
        // JavaScript code we will execute
        let jsSrc = "sin = Math.sin; cos = Math.cos; tan = Math.tan; log = Math.log; var f = function(x) { return \(expr); }; var df = function(x) { delta = 0.001; return (f(x + delta) - f(x)) / delta; };"
        
        // Create code and execute script, this will create the function inside the context
        let jsCtx = JSContext()!
        jsCtx.evaluateScript(jsSrc)
        
        // Get a reference to the function in the context
        guard let df = jsCtx.objectForKeyedSubscript("df") else {
            return nil
        }
        // If user inputs garbage and we can't evaluate, then exit
        if df.isUndefined {
            return nil
        }
        
        return { (x: Double) in return df.call(withArguments: [x])!.toDouble() }
    }
    
    func getCrossHairLocation() -> CGPoint? {
        return crosshairLoc
    }
    
    func getPanningDistance() -> CGPoint? {
        return panningVector
    }
    
    func getPinchScale() -> CGFloat? {
        return pintchScale
    }
    
    func dismissCrossHair() -> Bool {
        return dismissCrosshair
    }
    
    func setCrossingPoint(x_label: Double, y_label: Double, point: CGPoint) {
        crossingPointLabel.text = "(x = " + String(format: "%.1f", x_label) + ", y = " + String(format: "%.1f", y_label) + ")"
        crossingPointLabel.frame.origin = CGPoint(x: point.x + 5, y: point.y + 5)
    }
    
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        crosshairLoc = sender.location(in: plotView)
        plotView.setNeedsDisplay()
        dismissCrosshair = false;
        crossingPointLabel.isHidden = false;
    }
    
    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        panningVector = recognizer.translation(in: self.view)
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        plotView.setNeedsDisplay()
    }

    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer) {
        pintchScale = recognizer.scale
        recognizer.scale = 1
        plotView.setNeedsDisplay()
    }
    
    @IBAction func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        dismissCrosshair = true;
        crossingPointLabel.isHidden = true;
        plotView.setNeedsDisplay()
    }
}
