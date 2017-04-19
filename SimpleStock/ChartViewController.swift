//
//  ChartViewController.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/14/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import UIKit
import Charts

final class ChartViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var candleStickChartView: CandleStickChartView!
    
    // MARK: - IBActions
    
    final func refreshButtonPressed() {
        self.updateStockPoints()
    }

    // MARK: - Properties
    
    var stock: Stock?
    var stockPoints: [StockPoint]?
    var networkReachability = NetworkReachability()
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkReachability.delegate = self
        
        self.updateStockPoints()

        let noDataText = "No Data"
        lineChartView.noDataText = noDataText
        lineChartView.chartDescription?.text = ""
        candleStickChartView.noDataText = noDataText
        candleStickChartView.chartDescription?.text = ""
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonPressed))

        self.navigationItem.setRightBarButton(rightBarButton, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        networkReachability.startMonitoring()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        networkReachability.stopMonitoring()
    }
    
    // MARK: - Private functions
    
    final fileprivate func updateStockPoints() {
        
        let progressView = ProgressView(view: self.view, message: nil)
        
        progressView.showView()
        
        guard let stock = self.stock else {
            progressView.hideView()
            NotificationManager().presentSimpleAlertOn(vc: self, title: "Error!", message: "Please restart the app")
            return
        }
        
        StockData().updateStockPoints(stock: stock, timeRange: .OneMonth) { (success, error) in
            if !success {
                if let error = error { self.handleError(error: error) }
            } else {
                self.stockPoints = stock.points?.allObjects as? [StockPoint]
                self.reloadCharts()
            }
            
            progressView.hideView()
        }
    }
    
    final fileprivate func reloadCharts() {
        
        var lineDataEntries = [ChartDataEntry]()
        var candleDataEntries = [CandleChartDataEntry]()
    
        for index in (0..<self.stockPoints!.count - 1) {
        
            guard let stockPoint = self.stockPoints?[index] else {
                return
            }
            
            let close = Double (stockPoint.close)
            let open = Double (stockPoint.open)
            let high = Double (stockPoint.high)
            let low = Double (stockPoint.low)
            let index = Double (index)
            
            let historicQuote = (close + open + high + low) / 4
            
            let lineEntry = ChartDataEntry(x: index, y: historicQuote)
            let candleEntry = CandleChartDataEntry(x: index,
                                                   shadowH: high,
                                                   shadowL: low,
                                                   open: open,
                                                   close: close)
            
            lineDataEntries.append(lineEntry)
            candleDataEntries.append(candleEntry)
            
        }
        
        let lineChartDataSet = LineChartDataSet(values: lineDataEntries, label: "Historic Quote")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        self.lineChartView.xAxis.drawLabelsEnabled = false
        self.lineChartView.xAxis.drawAxisLineEnabled = false
        self.lineChartView.rightAxis.drawLabelsEnabled = false
        self.lineChartView.data = lineChartData

        let candleChartDataSet = CandleChartDataSet(values: candleDataEntries, label: "Historic Quote")
        let candleChartData = CandleChartData(dataSet: candleChartDataSet)
        self.candleStickChartView.xAxis.drawLabelsEnabled = false
        self.candleStickChartView.xAxis.drawAxisLineEnabled = false
        self.candleStickChartView.rightAxis.drawLabelsEnabled = false
        self.candleStickChartView.data = candleChartData
        
    }
    
    final fileprivate func handleError(error: StockDataError) {
        
        let title = "An error has occurred"
        var message = String()
        
        switch error {
            
        case .SaveError:
            message = "There was an issue saving your data"
        case .FetchError:
            message = "There was an issue fetching your data. Check internet connection"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Use old data if exists", style: .default, handler: nil)
        
        // Bonus feature states automatic update
//        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { (action) in
//            self.updateStockPoints()
//        }
        
//        alert.addAction(tryAgainAction)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
}

extension ChartViewController: NetworkReachabilityDelegate {
    
    func reachabilityChanged(status: NetworkReachabilityStatus) {
        
        switch status {
            
        case .unknown:
            return
        case .notReachable:
            return
        case .reachable:
            
            self.updateStockPoints()
            
            return
        }
        
    }
}
