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

// Get Date object for the beginning of the day a specified number of days ago
func daysAgo(_ days: Int) -> Date {
    let cal = Calendar.current
    return cal.date(byAdding: .day,
                    value: -days,
                    to: cal.startOfDay(for: Date()))!
}

// Represents a data point received from the perch
class ParticleDataPoint {
    let date: Date
    let value: Double
    
    init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
    
    func toWeight() -> Double {
        return abs(0.0011427 * self.value)
    }
    
    func toChartDataEntry(timeRange: LineChartViewController.TimeRange) -> ChartDataEntry {
        var x = 0.0
        switch timeRange {
        case .minute:
            x = self.date.timeIntervalSince(daysAgo(0)).truncatingRemainder(dividingBy: 60.0)
        case .day:
            x = self.date.timeIntervalSince(daysAgo(0)) / 3600.0
        case .week:
            x = self.date.timeIntervalSince(daysAgo(7 - 1)) / 86400.0
        case .month:
            x = self.date.timeIntervalSince(daysAgo(30 - 1)) / 86400.0
        case .year:
            x = self.date.timeIntervalSince(daysAgo(365 - 1)) / 86400.0
        }
        return ChartDataEntry(x: x, y: self.toWeight())
    }
}

class LineChartViewController: UIViewController, UITextFieldDelegate {
    
    // -------------------------------------------------------------------------
    // Initialization
    // -------------------------------------------------------------------------

    // Static class constants
    static let CHART_FONT = UIFont.systemFont(ofSize: 11)
    static let LEGEND_SQUARE_SIZE = CGFloat(16)
    static let NATHANS_CONSTANT = CGFloat(17)
    
    // View did load actions
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.noDataText = "No data available."
    }
    
    // View will appear actions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timeRange = TimeRange(rawValue: segmentedController.selectedSegmentIndex)!
        DataQueue.singleton.subscribe(prefix: "weight")
        plotLineChart(plotMode: PlotMode.initial)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.update()
        }
    }
    
    // -------------------------------------------------------------------------
    // IBOutlet variables
    // -------------------------------------------------------------------------
    
    // Line chart instance
    @IBOutlet var lineChartView: LineChartView!
    
    // Segment selector instance
    @IBOutlet weak var segmentedController: UISegmentedControl!
    enum TimeRange: Int {
        case minute = 0
        case day = 1
        case week = 2
        case month = 3
        case year = 4
    }
    var timeRange = TimeRange(rawValue: 0)!
    
    // -------------------------------------------------------------------------
    // IBAction handlers
    // -------------------------------------------------------------------------
    
    // Modify line chart whenever segment index changes
    @IBAction func segmentChanged(_ sender: Any) {
        timeRange = TimeRange(rawValue: segmentedController.selectedSegmentIndex)!
        plotLineChart(plotMode: PlotMode.initial)
    }
    
    // -------------------------------------------------------------------------
    // Helper functions
    // -------------------------------------------------------------------------
    
    // Get the specified number of past dates in [MM/DD] format
    func getPastDates(days: Int) -> [String] {
        let cal = Calendar.current
        let startDate = daysAgo(days - 1)
        return (0...days).map({ i -> String in
            let date = cal.date(byAdding: .day, value: i, to: startDate)!
            return String(cal.component(.month, from: date)) + "/" +
                   String(cal.component(.day, from: date))
        })
    }
    
    // Get x-axis labels based on the selected timeRange
    func getXLabels(timeRange: TimeRange) -> [String] {
        switch timeRange {
        case .minute:
            return (0...60).map({ ":" + String(format: "%02d", $0) })
        case .day:
            return ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM",
                    "7 AM", "8 AM", "9 AM", "10 AM", "11 AM",
                    "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM",
                    "7 PM", "8 PM", "9 PM", "10 PM", "11 PM", "12 AM"]
        case .week:
            return getPastDates(days: 7)
        case .month:
            return getPastDates(days: 30)
        case .year:
            return getPastDates(days: 365)
        }
    }
    
    // Get values from Particle device
    func getValues() -> [ParticleDataPoint] {
        var data = [ParticleDataPoint]()
        for str in DataQueue.singleton.queue {
            let components = str.components(separatedBy: "\t")
            if components.count != 2 {
                continue
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss yyyy"
            if let date = dateFormatter.date(from: components[1]),
               let value = Double(components[0]) {
                data.append(ParticleDataPoint(date: date, value: value))
            }
        }
        return data
    }
    
    // -------------------------------------------------------------------------
    // Plotting function
    // -------------------------------------------------------------------------
    
    enum PlotMode {
        case initial
        case update
    }
    
    func update() {
        plotLineChart(plotMode: PlotMode.update)
    }
    
    // Plot line chart given a time interval and values
    func plotLineChart(plotMode: PlotMode) {
        let xLabels = getXLabels(timeRange: timeRange)
        lineChartView.xAxis.valueFormatter =
            IndexAxisValueFormatter(values: xLabels)
        let values = getValues()
        var dataEntries = [ChartDataEntry]()
        for dataPoint in values {
            let cde = dataPoint.toChartDataEntry(timeRange: timeRange)
            if !dataEntries.isEmpty && cde.x < dataEntries.last!.x {
                dataEntries.removeAll()
            }
            dataEntries.append(cde)
        }
        let dataSet = LineChartDataSet(values: dataEntries,
                                       label: "Bird 1 weight (g)")
        dataSet.colors = [UIColor.black]
        dataSet.circleColors = [UIColor.black]
        dataSet.axisDependency = .left
        
        // Add data
        lineChartView.data = LineChartData(dataSet: dataSet)
        lineChartView.data!.setDrawValues(false)
        lineChartView.data!.setValueFont(LineChartViewController.CHART_FONT)
        
        // Average line
        lineChartView.leftAxis.removeAllLimitLines()
        let average = values.reduce(0, {$0 + $1.value}) / Double(values.count)
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
        lineChartView.xAxis.axisLineColor = UIColor.black
        lineChartView.xAxis.axisLineWidth = 2.0
        lineChartView.xAxis.axisMinimum = 0.0
        lineChartView.xAxis.labelFont = LineChartViewController.CHART_FONT
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelRotationAngle = -45.0
        switch timeRange {
        case .minute:
            lineChartView.xAxis.granularity = 1.0
            lineChartView.xAxis.labelCount = 13
            lineChartView.xAxis.axisMaximum = 60.0
        case .day:
            lineChartView.xAxis.granularity = 1.0
            lineChartView.xAxis.labelCount = 9
            lineChartView.xAxis.axisMaximum = 24.0
        case .week:
            lineChartView.xAxis.granularity = 1.0
            lineChartView.xAxis.labelCount = 7
            lineChartView.xAxis.axisMaximum = 7.0
        case .month:
            lineChartView.xAxis.granularity = 5.0
            lineChartView.xAxis.labelCount = 7
            lineChartView.xAxis.axisMaximum = 30.0
        case .year:
            lineChartView.xAxis.granularity = 1.0
            lineChartView.xAxis.labelCount = 12
            lineChartView.xAxis.axisMaximum = 365.0
        }
        
        // Left y-axis
        lineChartView.leftAxis.axisLineColor = UIColor.black
        lineChartView.leftAxis.axisLineWidth = 2.0
        lineChartView.leftAxis.axisMinimum = 0.0
        lineChartView.leftAxis.labelFont = LineChartViewController.CHART_FONT
        lineChartView.leftAxis.granularity = 1.0
 
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
        switch plotMode {
        case .initial:
            lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
        case .update:
            lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 0.0)
        }
        
        // Update graph with new changes
        lineChartView.notifyDataSetChanged()
    }
}
