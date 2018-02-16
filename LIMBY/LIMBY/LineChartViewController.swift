//
//  LineChartViewController.swift
//  LIMBY
//
//  Created by Nathan Tsai on 2/8/18.
//  Copyright © 2018 Nathan Tsai. All rights reserved.
//

import Foundation
import UIKit
import Charts

class LineChartViewController: UIViewController, UITextFieldDelegate {

    static let LEGEND_SQUARE_SIZE = CGFloat(16)
    static let CHART_FONT = UIFont.systemFont(ofSize: 11);
    static let LABEL_COUNT = 9
    static let NATHANS_CONSTANT = CGFloat(17)
    
    @IBOutlet var lineChartView: LineChartView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.noDataText = "No data available."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let sampleData = [1.0, 5.0, 3.0, 2.0, 4.0, 1.0, 5.0, 3.0, 2.0]
        setLineChart(timeRange: segmentedController.selectedSegmentIndex,
                     values: sampleData)
    }
    
    func setLineChart(timeRange: Int, values: [Double]) {

        // Custom x-axis labels
        let times = ["12 AM", "3 AM", "6 AM", "9 AM",
                     "12 PM", "3 PM", "6 PM", "9 PM", "12 AM"]
        lineChartView.xAxis.valueFormatter =
            IndexAxisValueFormatter(values: times)
        lineChartView.xAxis.granularity = 1
        
        // Process data
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<values.count {
            dataEntries.append(ChartDataEntry(x: Double(i), y: values[i]))
        }
        let dataSet = LineChartDataSet(values: dataEntries,
                                       label: "Bird 1 weight (g)")
        dataSet.colors = [ChartColorTemplates.liberty()[3]]
        dataSet.axisDependency = .left
        dataSet.drawCirclesEnabled = false
        
        // Add data
        lineChartView.data = LineChartData(dataSet: dataSet)
        lineChartView.data!.setDrawValues(false)
        lineChartView.data!.setValueFont(LineChartViewController.CHART_FONT)
        
        // Average line
        lineChartView.leftAxis.removeAllLimitLines()
        let average = 3.0
        if average > 0.0 {
            let ll = ChartLimitLine(limit: average,
                                    label: "Average: " + String(average))
            ll.lineColor = UIColor.black
            ll.valueFont = LineChartViewController.CHART_FONT
            ll.lineWidth = 1
            ll.labelPosition = .leftTop
            lineChartView.leftAxis.addLimitLine(ll)
        }
        
        // x-axis
        lineChartView.xAxis.axisMinimum = 0
        lineChartView.xAxis.labelCount = 10
        lineChartView.xAxis.labelFont = LineChartViewController.CHART_FONT
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelRotationAngle = -45
        
        // Left y-axis
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.labelCount = LineChartViewController.LABEL_COUNT
        lineChartView.leftAxis.labelFont = LineChartViewController.CHART_FONT
 
        // Right y-axis
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        
        // Description & legend
        lineChartView.chartDescription?.text = ""
        lineChartView.legend.font = LineChartViewController.CHART_FONT
        lineChartView.legend.formSize = LineChartViewController.LEGEND_SQUARE_SIZE
        
        // Margins
        lineChartView.extraLeftOffset = LineChartViewController.NATHANS_CONSTANT / 2
        lineChartView.extraRightOffset = LineChartViewController.NATHANS_CONSTANT
        lineChartView.extraTopOffset = LineChartViewController.NATHANS_CONSTANT
        lineChartView.extraBottomOffset = LineChartViewController.NATHANS_CONSTANT
        
        // Interaction
        lineChartView.backgroundColor = UIColor.white
        lineChartView.pinchZoomEnabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        
        // Animate
        lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
    }
}
