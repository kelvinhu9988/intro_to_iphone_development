//
//  FunctionPlottingView.swift
//  GraphingCalculator
//
//  Created by Daniel Hauagge on 9/14/16.
//  Copyright © 2016 Daniel Hauagge. All rights reserved.
//

import UIKit
import Foundation

protocol FunctionPlottingViewDelegate {
    func functionToPlot() -> ((Double) -> Double)?;
}

@IBDesignable
class FunctionPlottingView: UIView {
    
    var delegate : FunctionPlottingViewDelegate?
    var funcTransform = CGAffineTransform()
    var funcTransformInv = CGAffineTransform()
    
    var accumTranslation = CGPoint()
    var currTranslation = CGPoint()

    var currScale : CGFloat = 1.0
    var currScaleLocation : CGPoint?
    
    var corsshairLocTransformed : CGPoint?
    var crosshairLoc : CGPoint? {
        didSet {
            if crosshairLoc != nil {
                corsshairLocTransformed = crosshairLoc!.applying(funcTransformInv)
            } else {
                corsshairLocTransformed = nil
            }
        }
    }
    
    func pinchZoomTransform() -> CGAffineTransform {
        if currScaleLocation == nil {
            return CGAffineTransform.identity
        }
        
        var T = CGAffineTransform.identity
        T = T.translatedBy(x: currScaleLocation!.x, y: currScaleLocation!.y)
        T = T.scaledBy(x: currScale, y: currScale)
        T = T.translatedBy(x: -currScaleLocation!.x, y: -currScaleLocation!.y)
        
        return T
    }
    
    func updateTransform(_ rect: CGRect) {
        let scale : CGFloat = CGFloat(rect.width) / 2.0
        let transScale = CGAffineTransform(scaleX: scale, y: -scale)
        let transShift = CGAffineTransform(translationX: rect.midX, y: rect.midY)
        let transAccumTranslation = CGAffineTransform(translationX: accumTranslation.x + currTranslation.x, y: accumTranslation.y + currTranslation.y)

        let transPinchZoom = pinchZoomTransform()
        
        funcTransform = CGAffineTransform.identity
        funcTransform = transAccumTranslation.concatenating(funcTransform)
        funcTransform = transPinchZoom.concatenating(funcTransform)
        funcTransform = transShift.concatenating(funcTransform)
        funcTransform = transScale.concatenating(funcTransform)
        
        funcTransformInv = funcTransform.inverted()
    }
    
    func drawAxis(_ rect: CGRect) {
        let path = UIBezierPath()
        
        let rect_f = rect.applying(funcTransformInv)
        
        // X axis
        path.move(to: CGPoint(x: rect_f.minX, y: 0))
        path.addLine(to: CGPoint(x: rect_f.maxX, y: 0))
        path.lineWidth = 1
        
        // Y axis
        path.move(to: CGPoint(x: 0, y: rect_f.minY))
        path.addLine(to: CGPoint(x: 0, y: rect_f.maxY))
        path.lineWidth = 1

        // Stroke
        UIColor(red: 0.0, green: 150.0 / 255.0, blue: 1.0, alpha: 0.5).setStroke()
        path.apply(funcTransform)
        path.stroke()
    }
    
    func drawCrosshair(_ rect: CGRect) {
        if crosshairLoc == nil {
            return
        }

        let rect_f = rect.applying(funcTransformInv)

        #if TARGET_INTERFACE_BUILDER
            let f = { (x: Double) -> Double in x * x }
        #else
            guard let f = delegate?.functionToPlot() else {
                return
            }
        #endif

        var pnt = corsshairLocTransformed!
        pnt.y = CGFloat(f(Double(pnt.x)))
        let path = UIBezierPath()
        let pattern: [CGFloat] = [5.0, 5.0]
     
        // X axis
        path.move(to: CGPoint(x: rect_f.minX, y: pnt.y))
        path.addLine(to: CGPoint(x: rect_f.maxX, y: pnt.y))
        path.lineWidth = 1
        UIColor.lightGray.setStroke()
        path.apply(funcTransform)
        path.setLineDash(pattern, count: 2, phase: 0.0)
        path.stroke()
        
        // Y axis
        path.move(to: CGPoint(x: pnt.x, y: rect_f.minY))
        path.addLine(to: CGPoint(x: pnt.x, y: rect_f.maxY))
        path.lineWidth = 1
        UIColor.lightGray.setStroke()
        path.apply(funcTransform)
        path.setLineDash(pattern, count: 2, phase: 0.0)
        path.stroke()

        // Draw the point
        let text = NSString(format: "(x = %.1f, y = %.1f)", pnt.x, pnt.y)
        var labelLoc = pnt.applying(funcTransform)
        labelLoc.x += 10
        labelLoc.y += 10
        text.draw(at: labelLoc, withAttributes: nil)
    }
    
    func drawFunction(_ rect: CGRect) {
        let rect_f = rect.applying(funcTransformInv)
        
        #if TARGET_INTERFACE_BUILDER
            let f = { (x: Double) -> Double in x * x }
        #else
            guard let f = delegate?.functionToPlot() else {
                return
            }
            print(f)
        #endif
        
        // let transform = CGAffineTransformMakeTranslation(25, 25)
        
//        let path = UIBezierPath()
//        var p = CGPoint(x: Double(rect_f.minX), y: f(Double(rect_f.minX)))
//        if p.y.isNaN {
//            p.y = 1.0
//        }
//        
//        path.move(to: p)
//
//        for (_, x) in stride(from: (rect_f.minX), to: rect_f.maxX, by: (rect_f.maxX - rect_f.minX) / 1000.0).enumerated() {
//            let p = CGPoint(x: Double(x), y: f(Double(x)))
//            if p.y.isNaN {
//                continue
//            }
//            
//            path.addLine(to: p)
//        }
//        UIColor.red.setStroke()
//        path.apply(funcTransform)
//        path.lineWidth = 2
//        path.stroke()
        
        
        
        let path = UIBezierPath()
        UIColor.red.setStroke()
        if let f = delegate?.functionToPlot() {
            let xMin = Double(rect_f.minX)
            let xMax = Double(rect_f.maxX)
            
            var p = CGPoint(x:xMin, y: f(xMin))
            var prevPWasNormal = p.y.isNormal
            // print("p = \(p) is normal: \(p.y.isNormal)")
            path.move(to: p)
            
            
            let delta = (xMax - xMin) / 10000.0
            for x in stride(from: xMin, to: xMax, by: delta) {
                p = CGPoint(x: x, y: f(x))
                
                
                if p.y.isNormal {
                    if prevPWasNormal {
                        path.addLine(to: p)
                    } else {
                        path.move(to: p)
                        prevPWasNormal = true
                    }
                } else {
                    prevPWasNormal = false
                }
            }
        }
        path.apply(funcTransform)
        path.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        updateTransform(rect)
        drawAxis(rect)
        drawFunction(rect)
        drawCrosshair(rect)
        
        
        
    }
}
