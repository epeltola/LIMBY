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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.noDataText = "No data available."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let sampleData = [1.0, 5.0, 3.0, 2.0, 4.0]
        setLineChart(timeRange: segmentedController.selectedSegmentIndex,
                     values: sampleData)
    }
    
    func setLineChart(timeRange: Int, values: [Double]) {

        // Process data
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<values.count {
            dataEntries.append(ChartDataEntry(x: Double(i), y: values[i]))
            // let _ = barChartFormatter.stringForValue(Double(i), axis: xAxis)
        }
        let dataSet = LineChartDataSet(values: dataEntries, label: "Bird 1")
        dataSet.axisDependency = .left
        
        // Add data
        lineChartView.data = LineChartData(dataSet: dataSet)
        lineChartView.data?.setValueFont(UIFont.systemFont(ofSize: 11))
        
        // Other code
        // ---------------------------------------------------------------------
        
        // let barChartFormatter:BarChartFormatterWeek = BarChartFormatterWeek()
        // let xAxis:XAxis = XAxis()
        
        // xAxis.valueFormatter = barChartFormatter
        // barGraphView.xAxis.valueFormatter = xAxis.valueFormatter
        
        // Set a limit line to be the average amount spent in that week
        // let average = BudgetVariables.calculateAverage(nums: values)
        
        // Remove the average line from the previous graph
        //lineChartView.rightAxis.removeAllLimitLines();
        
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
        
        // Select the color scheme
        // chartDataSet.colors = ColorArray[BudgetVariables.budgetArray[BudgetVariables.currentIndex].barGraphColor]
        
        // Defaults
        //lineChartView.data?.setDrawValues(false)
        
        /*if BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.isEmpty == true || BudgetVariables.isAllZeros(array: values) == true {
            chartData.setDrawValues(false)
            barGraphView.rightAxis.drawLabelsEnabled = false
        }*/
        
        // Set where axis starts
        //lineChartView.setScaleMinima(0, scaleY: 0.0)
        
        /* let format = NumberFormatter()
        format.numberStyle = .currency
        let formatter = DefaultValueFormatter(formatter: format)
        chartData.setValueFormatter(formatter) */
        
        // Force all 7 x axis labels to show up
        // barGraphView.xAxis.setLabelCount(7, force: false)
        // ---------------------------------------------------------------------

        
        // x-axis
        //lineChartView.xAxis.axisMinimum = 0
        //lineChartView.xAxis.drawLabelsEnabled = true
        lineChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 11)
        //lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.labelPosition = .bottom
        
        // Left y-axis
        lineChartView.leftAxis.axisMinimum = 0
        //lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 11)
        //lineChartView.leftAxis.drawGridLinesEnabled = false
        //lineChartView.leftAxis.spaceBottom = 0
 
        // Right y-axis
        //lineChartView.rightAxis.axisMinimum = 0
        lineChartView.rightAxis.drawLabelsEnabled = false
        //lineChartView.rightAxis.labelFont = UIFont.systemFont(ofSize: 11)
        lineChartView.rightAxis.drawGridLinesEnabled = false
        //lineChartView.rightAxis.spaceBottom = 0
        
        // Description & legend
        lineChartView.chartDescription?.text = "This is the description."
        lineChartView.legend.font = UIFont.systemFont(ofSize: 11)
        //lineChartView.legend.formSize = 8
        
        // Interaction
        lineChartView.backgroundColor = UIColor.white
        lineChartView.pinchZoomEnabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        
        // Animate
        lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
    }
}
