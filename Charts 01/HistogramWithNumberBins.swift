//
//  HistogramWithNumberBins.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 8/21/22.
//

import SwiftUI
import Charts

struct HistogramWithNumberBins: View {
    let binnedData: [(ChartBinRange<Double>, Int)]
    @Environment(\.colorScheme) var colorScheme
    
    private var chart: some View {
        Chart(Array(binnedData.enumerated()), id: \.offset) { (_, rangeAndFreq) in
            BarMark(
                x: .value("Range", rangeAndFreq.0),
                y: .value("Frequency", rangeAndFreq.1)
            )
            .cornerRadius(0)
            .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
        .chartYScale(domain: 0.0...110.0)
        .chartYAxisLabel {
            HStack(spacing: 4) {
                Text("↑")
                Text("Frequency")
            }.offset(x: -10, y: -10)
        }
        .chartYAxis {
            AxisMarks(
                preset: .extended,
                position: .leading,
                values: .automatic(
                    desiredCount: 11, roundLowerBound: true, roundUpperBound: false
                )
            ) { _ in
                AxisValueLabel()
                    .font(.caption2)
                AxisTick(centered: false, length: 8, stroke: .init(lineWidth: 0.7))
                AxisGridLine(centered: true, stroke: .init(lineWidth: 0.5))
                    .foregroundStyle(.gray.opacity(0.4))
            }
        }
        .chartXScale(domain: 0...1.0)
        .chartXAxis {
            AxisMarks(preset: .aligned, position: .bottom, values: .stride(by: 0.1)) { value in
                AxisValueLabel()
                    .font(.caption2)
                AxisTick(centered: true, length: 9, stroke: .init(lineWidth: 1))
            }
        }
    }
    var body: some View {
        chart
            .padding()
    }
}

extension HistogramWithNumberBins {
    static let values = (0..<1000).map { _ in
        (Double.random(in: 0..<1.0) * Double.random(in: 0..<1.0))
    }

    static func bins() -> [(ChartBinRange<Double>, Int)] {
        let values = self.values
        let bins = NumberBins(data: values, desiredCount: 50)
        let grouping = Dictionary(grouping: values, by: bins.index)
        let chartData = grouping
            .map { (index, values) in
                (bins[index], values.count)
            }
        return chartData
    }

    static func sample() -> Self {
        HistogramWithNumberBins(binnedData: bins())
    }
}

struct HistogramWithNumberBins_Previews: PreviewProvider {
    static var previews: some View {
        HistogramWithNumberBins.sample()
            .frame(width: 640, height: 400)
    }
}
