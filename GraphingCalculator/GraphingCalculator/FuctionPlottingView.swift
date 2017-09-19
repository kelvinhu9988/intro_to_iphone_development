//
//  FunctionPlottingView.swift
//  GraphingCalculator
//
//  Created by Kelvin Hu on 9/9/17.
//  Copyright © 2017 Kelvin Hu. All rights reserved.
//

import UIKit

protocol FunctionPlottingViewDelegate
{
    func getFunctionToPlot() -> ((Double) -> Double)?
    func getFunctionDerivative() -> ((Double) -> Double)?
    func getCrossHairLocation() -> CGPoint?
    func getPanningDistance() -> CGPoint?
    func getPinchScale() -> CGFloat?
    func setCrossingPoint(x_label: Double, y_label: Double, point: CGPoint)
    func dismissCrossHair() -> Bool
}


class FunctionPlottingView: UIView
{
    
    var delegate: FunctionPlottingViewDelegate?
    
    // Coordinate Parameters
    var xMin = -3.0
    var xMax =  3.0
    var origin = CGPoint(x: 0.0, y: 0.0)
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect)
    {
        let delta = (xMax - xMin) / (5.0 * Double(rect.width))
        let scale = bounds.width / CGFloat(xMax - xMin)
        
        // T transforms the coordinate to the screen
        var T = CGAffineTransform.identity
        T = T.translatedBy(x: rect.midX, y: rect.midY)
        T = T.scaledBy(x: scale, y: -scale)
        
        // T_inverse transforms the screen to the coordinate
        let T_inverse = T.inverted()

        
        // Apply the panning effect
        let panning = self.delegate?.getPanningDistance()
        var panning_coordinate: CGPoint!
        if panning != nil
        {
            // Panning vector needs to be scaled to fit in the coordinate
            panning_coordinate = CGPoint(x: panning!.x / scale, y: panning!.y / -scale)
            xMin -= Float64(panning_coordinate.x)
            xMax -= Float64(panning_coordinate.x)
            origin.x += panning_coordinate.x
            origin.y += panning_coordinate.y
        }
        
        // Apply the pinch effect
        let pinchScale = self.delegate?.getPinchScale()
        if pinchScale != nil
        {
            xMin /= Double(pinchScale!)
            xMax /= Double(pinchScale!)
        }
        
        // Screen Parameters
        let origin_screen = origin.applying(T)
        
        // Draw axis
        var path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: origin_screen.y))
        path.addLine(to: CGPoint(x: rect.maxX, y: origin_screen.y))
        path.move(to: CGPoint(x: origin_screen.x, y: rect.minY))
        path.addLine(to: CGPoint(x: origin_screen.x, y: rect.maxY))
        UIColor.black.setStroke()
        path.stroke()
        
        // Draw function
        path = UIBezierPath()
        if let f = self.delegate?.getFunctionToPlot()
        {
            // Draw (xMin, f(xMin)) if the point is available
            if !f(xMin).isNaN
            {
                if f(xMin).isNormal
                {
                    var p = CGPoint(x: xMin, y: f(xMin))
                    p.x += origin.x
                    p.y += origin.y
                    if pinchScale != nil
                    {
                        p.x /= pinchScale!
                        p.y /= pinchScale!
                    }
                    p = p.applying(T)
                    
                    path.move(to: p)
                }
            }

            for x in stride(from: xMin, to: xMax, by: delta)
            {
                let y = f(x)
                if !y.isNaN
                {
                    if y.isNormal
                    {
                        var p = CGPoint(x: x, y: y)
                        p.x += origin.x
                        p.y += origin.y
                        if pinchScale != nil
                        {
                            p.x /= pinchScale!
                            p.y /= pinchScale!
                        }
                        p = p.applying(T)
                        
                        path.addLine(to: p)
                        path.move(to: p)
                    }
                }
                else
                {
                    if !f(x + delta).isNaN
                    {
                        var p = CGPoint(x: x + delta, y: f(x + delta))
                        p.x += origin.x
                        p.y += origin.y
                        if pinchScale != nil
                        {
                            p.x /= pinchScale!
                            p.y /= pinchScale!
                        }
                        p = p.applying(T)
                        
                        // Move the current point to the first point that becomes available
                        path.move(to: p)
                    }
                }
            }
            UIColor.darkGray.setStroke()
            path.lineWidth = 2.0
            path.stroke()
        }
        
        // Draw crosshair
        if self.delegate!.dismissCrossHair() == false
        {
            if let pnt = self.delegate?.getCrossHairLocation()
            {
                let vertical_line_x = pnt.x
                if let f = self.delegate!.getFunctionToPlot()
                {
                    path = UIBezierPath()
                    let dashes: [CGFloat] = [ 0.0, 8.0 ]
                    path.setLineDash(dashes, count: dashes.count, phase: 0.0)
                    path.lineWidth = 2.0
                    path.lineCapStyle = .round
                    
                    // Vertical line
                    path.move(to: CGPoint(x: vertical_line_x, y: rect.minY))
                    path.addLine(to: CGPoint(x: vertical_line_x, y: rect.maxY))
                    
                    let pnt_in_coordinate = pnt.applying(T_inverse)
                    
                    // Offset the panning distance based on how much the origin has shifted
                    let pnt_in_coordinate_after_pan = CGPoint(x: pnt_in_coordinate.x - origin.x, y: pnt_in_coordinate.y - origin.y)
                    
                    
                    let x_after_pan = Double(pnt_in_coordinate_after_pan.x)
                    let y_after_pan = f(x_after_pan)
                    if !y_after_pan.isNaN
                    {
                        let crossingPoint_after_pan = CGPoint(x: x_after_pan, y: y_after_pan)
                        let crossingPoing_before_pan = CGPoint(x: crossingPoint_after_pan.x + origin.x, y: crossingPoint_after_pan.y + origin.y)
                        
                        let crossingPoint_screen = crossingPoing_before_pan.applying(T)
                        // Horizontal line
                        path.move(to: CGPoint(x: rect.minX, y: crossingPoint_screen.y))
                        path.addLine(to: CGPoint(x: rect.maxX, y: crossingPoint_screen.y))
                        // Show the crossing point label
                        self.delegate?.setCrossingPoint(x_label: x_after_pan, y_label: y_after_pan, point: crossingPoint_screen)
                        
                        if let df = self.delegate?.getFunctionDerivative()
                        {
                            let slope = df(x_after_pan)
                            let f_tangent = { (x: Double) in return y_after_pan + slope * (x - x_after_pan) }
                            
                            let path_tangent = UIBezierPath()
                            let dashes: [CGFloat] = [ 0.0, 8.0 ]
                            path_tangent.setLineDash(dashes, count: dashes.count, phase: 0.0)
                            path_tangent.lineWidth = 2.0
                            path_tangent.lineCapStyle = .round
                            
                            var tangent_start = CGPoint(x: xMin, y: f_tangent(xMin))
                            tangent_start.x += origin.x
                            tangent_start.y += origin.y
                            tangent_start = tangent_start.applying(T)
                            path_tangent.move(to: tangent_start)
                            
                            var tangent_end = CGPoint(x: xMax, y: f_tangent(xMax))
                            tangent_end.x += origin.x
                            tangent_end.y += origin.y
                            tangent_end = tangent_end.applying(T)
                            path_tangent.addLine(to: tangent_end)
                            
                            UIColor.black.setStroke()
                            path_tangent.stroke()
                        }
                    }
                    else
                    {
                        path.move(to: CGPoint(x: vertical_line_x, y: rect.minY))
                        path.addLine(to: CGPoint(x: vertical_line_x, y: rect.maxY))
                    }
                    UIColor.lightGray.setStroke()
                    path.stroke()
                }
            }
        }
    }
}
