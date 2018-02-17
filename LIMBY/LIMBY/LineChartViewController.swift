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
    
    // --------------
    // Initialization
    // --------------

    // Static class constants
    static let LEGEND_SQUARE_SIZE = CGFloat(16)
    static let CHART_FONT = UIFont.systemFont(ofSize: 11)
    static let YLABEL_COUNT = 9
    static let NATHANS_CONSTANT = CGFloat(17)
    
    // View did load actions
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.noDataText = "No data available."
    }
    
    // View will appear actions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let sampleData = [1.0, 5.0, 3.0, 2.0, 4.0, 1.0, 5.0, 3.0, 2.0]
        plotLineChart(timeRange: segmentedController.selectedSegmentIndex,
                      values: sampleData)
    }
    
    // ------------------
    // IBOutlet variables
    // ------------------
    
    // Line chart instance
    @IBOutlet var lineChartView: LineChartView!
    
    // Segment selector instance
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    // -----------------
    // IBAction handlers
    // -----------------
    
    // Modify line chart whenever segment index changes
    @IBAction func segmentChanged(_ sender: Any) {
        let index = segmentedController.selectedSegmentIndex
        switch index {
        case 0:
            let sampleData = [1.0, 5.0, 3.0, 2.0,
                              4.0, 1.0, 5.0, 3.0,
                              2.0]
            plotLineChart(timeRange: index, values: sampleData)
        case 1:
            let sampleData = [5.0, 3.0, 2.0, 4.0,
                              1.0, 2.0, 8.0]
            plotLineChart(timeRange: index, values: sampleData)
        case 2:
            let sampleData = [3.0, 1.0, 4.0, 1.0,
                              5.0, 4.0, 1.0, 2.0,
                              4.0, 9.0, 2.0, 8.0,
                              12.0, 4.0, 5.0, 2.0,
                              3.0, 1.0, 4.0, 1.0,
                              5.0, 4.0, 1.0, 2.0,
                              4.0, 9.0, 2.0, 8.0,
                              3.0, 1.0, 4.0]
            plotLineChart(timeRange: index, values: sampleData)
        case 3:
            let sampleData = [2.0, 4.0, 1.0, 2.0,
                              7.0, 4.0, 1.0, 5.0,
                              10.0, 2.0, 8.0, 3.0]
            plotLineChart(timeRange: index, values: sampleData)
        default:
            print("Invalid segment index")
        }
    }
    
    // ----------------
    // Helper functions
    // ----------------
    
    // Get past 7 or 31 days into String array in [MM/DD] format
    func getDateInterval(interval: String) -> [String] {
        var size = 7
        if (interval == "Month") {
            size = 31
        }
        let cal = Calendar.current
        var dayIndex = cal.date(byAdding: .day, value: ((size - 1) * -1), to: cal.startOfDay(for: Date()))
        var days = [String]()
        for _ in 1 ... size {
            let day = cal.component(.day, from: dayIndex!)
            let month = cal.component(.month, from: dayIndex!)
            days.append(String(month) + "/" + String(day))
            dayIndex = cal.date(byAdding: .day, value: 1, to: dayIndex!)!
        }
        return days
    }
    
    // Get past twelve months into String array in [Mmm] format
    func getPastTwelveMonths() -> [String] {
        let cal = Calendar.current
        let monthIndex = cal.component(.month, from: cal.startOfDay(for: Date()))
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
                      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let monthSliceArray = months[monthIndex...monthIndex + 11]
        return [String](Array(monthSliceArray))
    }
    
    // Plot line chart given a time interval and values
    func plotLineChart(timeRange: Int, values: [Double]) {
        
        // Custom x-axis labels
        var xLabels = [String]()
        switch timeRange {
        case 0:
            xLabels = ["12 AM", "3 AM", "6 AM", "9 AM",
                     "12 PM", "3 PM", "6 PM", "9 PM",
                     "12 AM"]
        case 1:
            xLabels = getDateInterval(interval: "Week")
        case 2:
            xLabels = getDateInterval(interval: "Month")
        case 3:
            xLabels = getPastTwelveMonths()
        default:
            print("Invalid segment index")
        }
        lineChartView.xAxis.valueFormatter =
            IndexAxisValueFormatter(values: xLabels)
        switch timeRange {
        case 0, 1, 3:
            lineChartView.xAxis.granularity = 1
        case 2:
            lineChartView.xAxis.granularity = 5
        default:
            lineChartView.xAxis.granularity = 1
        }
        
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
        let average = values.reduce(0, +) / Double(values.count)
        if average > 0.0 {
            let ll = ChartLimitLine(limit: average,
                                    label: "Average: " + String(format: "%.2f", average))
            ll.lineColor = UIColor.black
            ll.valueFont = LineChartViewController.CHART_FONT
            ll.lineWidth = 2
            ll.labelPosition = .leftTop
            lineChartView.leftAxis.addLimitLine(ll)
        }
        
        // x-axis
        switch timeRange {
        case 0, 1, 3:
            lineChartView.xAxis.labelCount = values.count
        case 2:
            lineChartView.xAxis.labelCount = 7
        default:
            lineChartView.xAxis.labelCount = values.count
        }
        lineChartView.xAxis.axisMinimum = 0
        lineChartView.xAxis.labelFont = LineChartViewController.CHART_FONT
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelRotationAngle = -45
        
        // Left y-axis
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.labelCount = LineChartViewController.YLABEL_COUNT
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
        lineChartView.extraBottomOffset = 0
        
        // Interaction
        lineChartView.backgroundColor = UIColor.white
        lineChartView.pinchZoomEnabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        
        // Animate
        lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
        
        // Update graph with new changes
        lineChartView.notifyDataSetChanged()
    }
}
