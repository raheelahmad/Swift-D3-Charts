//
//  D3BoxPlot.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 9/14/22.
//

import SwiftUI
import SwiftCSV
import Charts

struct D3BoxPlot: View {
    @State var prices: [BinnedCaratPrice]

    @Environment(\.colorScheme) var colorScheme

    private let boxWidth: Double = 40.0
    private var chart: some View {
        Chart {
            ForEach(prices) { binnedPrices in
                ForEach(binnedPrices.outliers) { price in
                    PointMark(
                        x: .value("Alphabet", binnedPrices.x),
                        y: .value("Frequency", price.price)
                    )
                    .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.4))
                    .symbolSize(12.0)
                }


                if binnedPrices.values.count > 1 {
                    BarMark(
                        x: .value("Alphabet", binnedPrices.x),
                        yStart: .value("3rd Quartile", binnedPrices.firstQuartile),
                        yEnd: .value("1st Quartile", binnedPrices.thirdQuartile),
                        width: 30
                    ).foregroundStyle(colorScheme == .dark ? Color(white: 0.4) : Color(white: 0.7))
                }

                if binnedPrices.values.count > 0 {
                    BarMark(
                        x: .value("Alphabet", binnedPrices.x),
                        yStart: .value("1st Quartile", binnedPrices.median),
                        yEnd: .value("Minimum", binnedPrices.median + 20),
                        width: 30
                    ).foregroundStyle(colorScheme == .dark ? Color.white : Color.black)

                }
            }
        }
        .d3YAxisLabel("Price ($)")
        .chartXAxisLabel(position: .bottom, alignment: .trailing) {
            Text("Carats →")
                .offset(x: 16, y: -4)
        }
        .chartYAxis {
                AxisMarks(
                    preset: .aligned,
                    position: .leading,
                    values: .stride(by: 2000)
                ) { val in
                    AxisValueLabel()
                    AxisTick(
                        centered: false,
                        length: 8,
                        stroke: .init(lineWidth: 0.5)
                    )

                    AxisGridLine(centered: true, stroke: .init(lineWidth: 0.5))
                        .foregroundStyle(.gray.opacity(val.index == 0 ? 1.0 : 0.2))
                }

        }
        .chartXScale(domain: 0.2...5.2)
        .chartXAxis {
            AxisMarks(preset: .aligned, position: .bottom, values: .stride(by: 0.2)) { value in
                AxisValueLabel()
                    .font(.caption2)
                AxisTick(centered: true, length: 9, stroke: .init(lineWidth: 1))
            }
        }
    }

    private var link: some View {
        D3LinkView(url: URL(string: "https://observablehq.com/@d3/box-plot?collection=@d3/charts")!)
    }

    var body: some View {
        VStack(alignment: .leading) {
            link
            chart
                .padding(20)
        }
        .padding()
    }
}

extension Collection where Element == Double, Index == Int {
    var median: Double {
        guard count > 0 else {
            fatalError()
        }

        if count % 2 == 0 {
            return (self[count/2 - 1] + self[count/2])/2
        } else {
            let idx = count / 2
            return self[idx]
        }
    }

    var firstQuartile: Double {
        let endIndex = Int(Double(self.count) * 0.25)
        let lowerHalf = Array(self[...endIndex])
        return lowerHalf.median
    }

    var thirdQuartile: Double {
        let endIndex = Int(Double(self.count) * 0.75)
        let upperHalf = Array(self[endIndex...])
        return upperHalf.median
    }
}

struct BinnedCaratPrice: Identifiable {
    let x: Double
    let values: [CaratPrice]
    var outliers: [CaratPrice] = []

    init(x: Double, values: [CaratPrice]) {
        self.x = x
        self.values = values

        if values.count > 1 {
            let iqr = thirdQuartile - firstQuartile
            let r0 = Swift.max(min, firstQuartile - iqr * 1.5)
            let r1 = Swift.min(max, thirdQuartile + iqr * 1.5)
            self.outliers = values.filter { $0.price < r0 || $0.price > r1 }
        } else {
            self.outliers = []
        }
    }

    var id: Double { x }

    var sortedPrices: [Double] {
        values.map(\.price).sorted()
    }

    var min: Double {
        sortedPrices.min() ?? 0
    }

    var max: Double {
        sortedPrices.max() ?? 0
    }

    var median: Double {
        sortedPrices.median
    }

    var firstQuartile: Double { sortedPrices.firstQuartile }

    var thirdQuartile: Double {sortedPrices.thirdQuartile}
}

struct CaratPrice: Identifiable {
    let index: Int
    var id: Int { index }

    let carat: Double
    let price: Double
}

extension D3BoxPlot {
    static func caratPrices() -> [BinnedCaratPrice] {
        let csv = try! NamedCSV(url: Bundle.main.url(forResource: "diamonds", withExtension: "csv")!)
        let weights = csv.rows.enumerated().map { (idx, row) in
            CaratPrice(index: idx, carat: Double(row["carat"]!)!, price: Double(row["price"]!)!)
        }

        let values = weights.map(\.carat)
        let bins = NumberBins(data: values, desiredCount: 20)
        let grouping = Dictionary(grouping: weights, by: { weight in
            return bins.index(for: weight.carat)
        })

        return bins.enumerated().map { (idx, bin) in
            let x = (bin.upperBound - bin.lowerBound)/2.0 + bin.lowerBound
            let values = grouping[idx] ?? []
            return BinnedCaratPrice(x: x, values: values)
        }
    }

    static var sample: Self {
        D3BoxPlot(prices: caratPrices())
    }
}

struct D3BoxPlot_Previews: PreviewProvider {
    static var previews: some View {
        D3BoxPlot.sample
            .frame(width: 640, height: 400)
    }
}
