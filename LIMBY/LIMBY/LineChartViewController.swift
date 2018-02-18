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
    
    // -------------------------------------------------------------------------
    // Initialization
    // -------------------------------------------------------------------------

    // Static class constants
    static let CHART_FONT = UIFont.systemFont(ofSize: 11)
    static let LEGEND_SQUARE_SIZE = CGFloat(16)
    static let NATHANS_CONSTANT = CGFloat(17)
    static let YLABEL_COUNT = 10
    
    // View did load actions
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.noDataText = "No data available."
    }
    
    // View will appear actions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        plotLineChart(timeRange: segmentedController.selectedSegmentIndex)
    }
    
    // -------------------------------------------------------------------------
    // IBOutlet variables
    // -------------------------------------------------------------------------
    
    // Line chart instance
    @IBOutlet var lineChartView: LineChartView!
    
    // Segment selector instance
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    // -------------------------------------------------------------------------
    // IBAction handlers
    // -------------------------------------------------------------------------
    
    // Modify line chart whenever segment index changes
    @IBAction func segmentChanged(_ sender: Any) {
        plotLineChart(timeRange: segmentedController.selectedSegmentIndex)
    }
    
    // -------------------------------------------------------------------------
    // Helper functions
    // -------------------------------------------------------------------------
    
    // Get the specified number of past dates in [MM/DD] format
    func getPastDates(days: Int) -> [String] {
        let cal = Calendar.current
        let startDate = cal.date(byAdding: .day, value: -days + 1,
                                 to: cal.startOfDay(for: Date()))!
        return (0..<days).map({ i -> String in
            let date = cal.date(byAdding: .day, value: i, to: startDate)!
            return String(cal.component(.month, from: date)) + "/" +
                   String(cal.component(.day, from: date))
        })
    }
    
    // Get x-axis labels based on the selected timeRange
    func getXLabels(timeRange: Int) -> [String] {
        switch timeRange {
        case 0:  // day
            return ["12 AM", "3 AM", "6 AM", "9 AM",
                    "12 PM", "3 PM", "6 PM", "9 PM", "12 AM"]
        case 1:  // week
            return getPastDates(days: 7)
        case 2:  // month
            return getPastDates(days: 31)
        case 3:  // year
            let cal = Calendar.current
            let monthIndex =
                cal.component(.month, from: cal.startOfDay(for: Date()))
            let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
                          "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            return Array(months[monthIndex...monthIndex + 11])
        default:
            print("getXLabels: Invalid timeRange!")
            return []
        }
    }
    
    // Get sample values (for testing) based on the selected timeRange
    func getSampleValues(timeRange: Int) -> [Double] {
        switch timeRange {
        case 0:  // day
            return [1.0, 5.0, 3.0, 2.0, 4.0, 1.0, 5.0, 3.0, 2.0]
        case 1:  // week
            return [5.0, 3.0, 2.0, 4.0, 1.0, 2.0, 8.0]
        case 2:  // month
            return [3.0, 1.0, 4.0, 1.0, 5.0, 4.0, 1.0,
                    2.0, 4.0, 9.0, 2.0, 8.0, 2.0, 4.0,
                    5.0, 2.0, 3.0, 1.0, 4.0, 1.0, 5.0,
                    4.0, 1.0, 2.0, 4.0, 9.0, 2.0, 8.0,
                    3.0, 1.0, 4.0]
        case 3:  // year
            return [2.0, 4.0, 1.0, 2.0, 7.0, 4.0,
                    1.0, 5.0, 10.0, 2.0, 8.0, 3.0]
        default:
            print("getSampleValues: Invalid timeRange!")
            return []
        }
    }
    
    // Plot line chart given a time interval and values
    func plotLineChart(timeRange: Int, inputValues: [Double]? = nil) {
        let values = inputValues ?? getSampleValues(timeRange: timeRange)
        let xLabels = getXLabels(timeRange: timeRange)
        lineChartView.xAxis.valueFormatter =
            IndexAxisValueFormatter(values: xLabels)
        
        // Process data
        let dataEntries = (0..<values.count).map({ i -> ChartDataEntry in
            return ChartDataEntry(x: Double(i), y: values[i])
        })
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
            let ll = ChartLimitLine(limit: average, label: "Average: " +
                                    String(format: "%.2f", average))
            ll.lineColor = UIColor.black
            ll.valueFont = LineChartViewController.CHART_FONT
            ll.lineWidth = 2
            ll.labelPosition = .leftTop
            lineChartView.leftAxis.addLimitLine(ll)
        }
        
        // x-axis
        lineChartView.xAxis.axisMinimum = 0.0
        lineChartView.xAxis.labelFont = LineChartViewController.CHART_FONT
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelRotationAngle = -45.0
        switch timeRange {
        case 0:  // day
            lineChartView.xAxis.granularity = 1.0
            lineChartView.xAxis.labelCount = 9
        case 1:  // week
            lineChartView.xAxis.granularity = 1.0
            lineChartView.xAxis.labelCount = 7
        case 2:  // month
            lineChartView.xAxis.granularity = 5.0
            lineChartView.xAxis.labelCount = 7
        case 3:  // year
            lineChartView.xAxis.granularity = 1.0
            lineChartView.xAxis.labelCount = 12
        default:
            print("plotLineChart: Invalid timeRange!")
        }
        
        // Left y-axis
        lineChartView.leftAxis.axisMinimum = 0.0
        lineChartView.leftAxis.labelCount = LineChartViewController.YLABEL_COUNT
        lineChartView.leftAxis.labelFont = LineChartViewController.CHART_FONT
        lineChartView.leftAxis.granularity = 1.0
        if let max = values.max() {
            lineChartView.leftAxis.axisMaximum = (max + 1).rounded(.towardZero)
        }
 
        // Right y-axis
        lineChartView.rightAxis.enabled = false
        
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
