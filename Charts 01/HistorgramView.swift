//
//  ContentView.swift
//  Charts01
//
//  Created by Raheel on 8/19/22.
//

import SwiftUI
import Charts

let binsCount = 50
let binSize = 1.0 / Double(binsCount)

struct Bin: Hashable, Identifiable, Plottable {
    let lower: Double
    let higher: Double
    
    var id: Double { lower }
    
    var primitivePlottable: Double { (lower + higher)/2 }
    
    init(lower: Double, higher: Double) {
        self.lower = lower
        self.higher = higher
    }
    
    init?(primitivePlottable: Double) {
        self.lower = primitivePlottable - binSize / 2
        self.higher = primitivePlottable + binSize / 2
    }
}

struct Frequency: Identifiable {
    let bin: Bin
    let frequency: Int
    var id: Bin { bin }
}

func calcuateFrequencies(_ values: [Double]) -> [Frequency] {
    let bins = (0..<binsCount).map { idx in
        Bin(
            lower: (Double(idx) * binSize),
            higher: (Double(idx) + 1) * binSize
        )
    }
    var result: [Bin: Int] = [:]
    
    for val in values {
        guard let bin = bins.first(where: { $0.lower <= val && $0.higher > val }) else { continue }
        result[bin] = result[bin, default: 0] + 1
    }
    
    return result.sorted { $0.value < $1.value }.map(Frequency.init)
}

struct SimpleHistogram: View {
    let frequencies: [Frequency]
    
    private var chart: some View {
        Chart {
            ForEach(frequencies) { frequency in
                BarMark(
                    x: .value("Range", frequency.bin),
                    y: .value("Frequency", frequency.frequency)
                )
            }
        }
        .chartLegend(.visible)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(
                preset: .automatic,
                position: .bottom,
                values: .automatic(desiredCount: 10, roundLowerBound: true, roundUpperBound: false),
                stroke: .init(lineWidth: 1)
            )
        }
//        .chartXScale(domain: 0 ... 1.99)
    }
    
    var body: some View {
        VStack {
            chart
        }
    }
}


struct HistogramView_Previews: PreviewProvider {
    static let values = (0..<1000).map { _ in
        (Double.random(in: 0..<1.0)
                * Double.random(in: 0..<1.0))
        
    }
    static var previews: some View {
        SimpleHistogram(
            frequencies: calcuateFrequencies(values)
        )
    }
}
