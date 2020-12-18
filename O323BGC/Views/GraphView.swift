//
//  GraphView.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 12/12/2020.
//

import Cocoa

@IBDesignable
class GraphView: NSView {
    
    @IBInspectable var startColor: NSColor = .red
    @IBInspectable var endColor: NSColor = .green

    private enum Constants {
      static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
      static let margin: CGFloat = 20.0
      static let topBorder: CGFloat = 10
      static let bottomBorder: CGFloat = 10
      static let colorAlpha: CGFloat = 0.3
      static let circleDiameter: CGFloat = 5.0
        static let lineColors: [NSColor] = [ .white, .red, .green, .blue]
    }
    
    var graphPoints = Array(repeating: Array(repeating: Float(0), count: 4), count: 100)
    var marker = 0
    
    func append(values: [Float]) {
        graphPoints[marker] = values
        marker += 1
        if (marker > graphPoints.count-1) {
            marker = 0
        }
    }
    
    var yRangeMax = 180.0 {
        didSet {
            self.setNeedsDisplay(bounds)
        }
    }
    var yRangeMin = -180.0 {
        didSet {
            self.setNeedsDisplay(bounds)
        }
    }
    
    func updateView() {
        self.setNeedsDisplay(bounds)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current else {
            return
        }
        let cgContext = context.cgContext
        
        // Clips to create rounded corners
        let path: NSBezierPath = NSBezierPath()
        path.appendRoundedRect(dirtyRect, xRadius: Constants.cornerRadiusSize.width, yRadius: Constants.cornerRadiusSize.height)
        path.addClip()

        // Creates a nice gradient
        let colors = [ startColor.cgColor, endColor.cgColor, startColor.cgColor ]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 0.5, 1.0]

        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations) else {
            return
        }
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        cgContext.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        
        let margin = Constants.margin
        let topBorder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder

        let width = dirtyRect.width
        let height = dirtyRect.height
        let graphWidth = width - margin * 2 - 4
        let graphHeight = height - topBorder - bottomBorder
        let heightDelta = yRangeMax - yRangeMin

        let linePath = NSBezierPath()
        // Top line
        linePath.move(to: CGPoint(x: margin, y: topBorder))
        linePath.line(to: CGPoint(x: width - margin, y: topBorder))

        // Center line
        linePath.move(to: CGPoint(x: margin, y: graphHeight / 2 + topBorder))
        linePath.line(to: CGPoint(x: width - margin, y: graphHeight / 2 + topBorder))

        // Bottom line
        linePath.move(to: CGPoint(x: margin, y: height - bottomBorder))
        linePath.line(to: CGPoint(x: width - margin, y: height - bottomBorder))
        let color = NSColor(white: 1.0, alpha: Constants.colorAlpha)
        color.setStroke()
            
        linePath.lineWidth = 1.0
        linePath.setLineDash([ 5.0, 2.0], count: 2, phase: 0.0)
        linePath.stroke()

        let linePath2 = NSBezierPath()
        // Top Half line
        linePath2.move(to: CGPoint(x: margin, y: topBorder + (graphHeight / 4)))
        linePath2.line(to: CGPoint(x: width - margin, y: topBorder + (graphHeight / 4)))

        // Bottom Half line
        linePath2.move(to: CGPoint(x: margin, y: height - bottomBorder - (graphHeight / 4)))
        linePath2.line(to: CGPoint(x: width - margin, y: height - bottomBorder - (graphHeight / 4)))

        linePath2.lineWidth = 1.0
        linePath2.setLineDash([ 2.0, 2.0], count: 2, phase: 0.0)
        linePath2.stroke()
                
        let columnXPoint = { (column: Int) -> CGFloat in
          // Calculate the gap between points
          let spacing = graphWidth / CGFloat(self.graphPoints.count - 1)
          return CGFloat(column) * spacing + margin + 2
        }

        let columnYPoint = { (graphPoint: Float) -> CGFloat in
            let yPoint = CGFloat(Float(heightDelta) - ( graphPoint - Float(self.yRangeMin))) / CGFloat(heightDelta) * graphHeight
          return graphHeight + topBorder - yPoint // Flip the graph
        }
            
        for line in 1..<graphPoints[0].count {
            Constants.lineColors[line].setFill()
            Constants.lineColors[line].setStroke()

            // Set up the points line
            let graphPath = NSBezierPath()

            // Go to start of line
            graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(graphPoints[0][line])))
                
            // Add points for each item in the graphPoints array
            // at the correct (x, y) for the point
            for index in 1..<graphPoints.count {
              let nextPoint = CGPoint(x: columnXPoint(index), y: columnYPoint(graphPoints[index][line]))
              graphPath.line(to: nextPoint)
            }

            graphPath.stroke()
        }
    }    
}
