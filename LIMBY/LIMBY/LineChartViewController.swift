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
 
    @IBOutlet var lineChartView: LineChartView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    // Initially load delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If there is no data
        lineChartView.noDataText = "No data available."
    }
    
    // Load the graph before view appears. We do this here because data may change
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let sampleData = [1.0, 5.0, 3.0, 2.0, 4.0]
        setLineChart(timeRange: segmentedController.selectedSegmentIndex, values: sampleData)
    }
    
    // Set Line Graph
    func setLineChart(timeRange: Int, values: [Double]) {
        // let barChartFormatter:BarChartFormatterWeek = BarChartFormatterWeek()
        // let xAxis:XAxis = XAxis()
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<values.count {
            dataEntries.append(ChartDataEntry(x: Double(i), y: values[i]))
            
            // let _ = barChartFormatter.stringForValue(Double(i), axis: xAxis)
        }
        
        let dataSet = LineChartDataSet(values: dataEntries, label: "Generic Perch Data")
        
        // xAxis.valueFormatter = barChartFormatter
        // barGraphView.xAxis.valueFormatter = xAxis.valueFormatter
        
        // Set a limit line to be the average amount spent in that week
        // let average = BudgetVariables.calculateAverage(nums: values)
        
        // Remove the average line from the previous graph
        lineChartView.rightAxis.removeAllLimitLines();
        
        // Only add the average line if there is actually data in the bar graph
        /*if average != 0.0
        {
            let ll = ChartLimitLine(limit: average, label: "Average: " + BudgetVariables.numFormat(myNum: average))
            ll.lineColor = BudgetVariables.hexStringToUIColor(hex: "092140")
            ll.valueFont = UIFont.systemFont(ofSize: 12)
            ll.lineWidth = 2
            ll.labelPosition = .leftTop
            barGraphView.rightAxis.addLimitLine(ll)
        }*/
        
        // Set the position of the x axis label
        // lineChartView.rightAxis.axisMinimum = 0
        // lineChartView.xAxis.labelPosition = .bottom
        
        // Select the color scheme
        // chartDataSet.colors = ColorArray[BudgetVariables.budgetArray[BudgetVariables.currentIndex].barGraphColor]
        
        // chartDataSet.axisDependency = .right
        lineChartView.data = LineChartData(dataSet: dataSet)
        
        // Legend font size
        // barGraphView.legend.font = UIFont.systemFont(ofSize: 13)
        // barGraphView.legend.formSize = 8
        
        // Defaults
        // chartData.setDrawValues(true)
        // barGraphView.rightAxis.drawLabelsEnabled = true
        
        /*if BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.isEmpty == true || BudgetVariables.isAllZeros(array: values) == true {
            chartData.setDrawValues(false)
            barGraphView.rightAxis.drawLabelsEnabled = false
        }*/
        
        // Set where axis starts
        // barGraphView.setScaleMinima(0, scaleY: 0.0)
        
        // Customization
        /*barGraphView.pinchZoomEnabled = false
        barGraphView.scaleXEnabled = false
        barGraphView.scaleYEnabled = false
        barGraphView.xAxis.drawGridLinesEnabled = false
        barGraphView.leftAxis.drawGridLinesEnabled = false
        barGraphView.rightAxis.drawGridLinesEnabled = false
        barGraphView.leftAxis.drawLabelsEnabled = false
        barGraphView.rightAxis.spaceBottom = 0
        barGraphView.leftAxis.spaceBottom = 0*/
        
        // Set font size
        // chartData.setValueFont(UIFont.systemFont(ofSize: 12))
        
        /* let format = NumberFormatter()
        format.numberStyle = .currency
        let formatter = DefaultValueFormatter(formatter: format)
        chartData.setValueFormatter(formatter) */
        
        // Set Y Axis Font
        // barGraphView.rightAxis.labelFont = UIFont.systemFont(ofSize: 11)
        
        // Set X Axis Font
        // barGraphView.xAxis.labelFont = UIFont.systemFont(ofSize: 13)
        
        // Force all 7 x axis labels to show up
        // barGraphView.xAxis.setLabelCount(7, force: false)
        
        // Set description texts
        lineChartView.chartDescription?.text = "This is the description."
        
        // Set the background color
        // barGraphView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        // Animate the chart
        lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.5)
    }
}
