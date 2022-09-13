//
//  D3Beeswarm.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 9/12/22.
//

import SwiftUI
import Charts
import SwiftCSV

struct Weight: Identifiable, Hashable {
    let id = UUID()
    let weight: Double
}

extension Array where Element == Weight {
    func dodgedYs(radius: Double, padding: Double) -> [Double] {
        var ys: [Double] = []
        var positions: [Weight: Double] = [:]
        func nearEachOther(w1: Weight, w2: Weight) -> Bool {
            abs(w1.weight - w2.weight) < 24
        }
        for item in self {
            let nearCount = positions
                .filter { nearEachOther(w1: $0.key, w2: item) }
                .count
            let y = Double(nearCount) * radius/2
            ys.append(y)
            positions[item] = y
        }

        return ys
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}


/// Recreating the [beeswarm](https://observablehq.com/@d3/beeswarm?collection=@d3/charts)
struct D3Beeswarm: View {
    let weights: [Weight]
    private let radius: Double = 20
    @State private var ys: [Double] = []
    @State private var chartFrame: CGRect = .zero
    @Environment(\.colorScheme) var colorScheme

    private var chart: some View {
        Chart(Array(weights.enumerated()), id: \.element) { (idx, weight) in
            PointMark(
                x: .value("Range", weight.weight),
                y: .value("Frequency", 20)
            )
            .offset(y: ys.count > idx ? ys[idx] : 0)
            .symbolSize(radius * 2)
            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
        }
        .chartYAxis {
            AxisMarks(preset: .aligned) { val in
                if val.index == 0 {
                    AxisGridLine()
                }
            }
        }
        .chartYAxisLabel(position: .bottom) {
            Text("Weight(lbs.) →")
                .offset(x: -20, y: -5)
        }
        .chartXScale(domain: 1600...5200)
        .chartXAxis {
            AxisMarks(preset: .aligned, position: .bottom, values: .stride(by: 500)) { value in
                AxisValueLabel()
                    .font(.caption2)
                AxisTick(centered: true, length: 9, stroke: .init(lineWidth: 1))
            }
        }
        .chartOverlay { proxy in
            GeometryReader { reader in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: reader[proxy.plotAreaFrame])
            }
        }
        .onPreferenceChange(SizePreferenceKey.self, perform: { frame in
            let height = frame.size.height
            let ys = weights.dodgedYs(radius: radius, padding: 0)
                .map { height - $0 - 10 }
            self.ys = ys
        })
        .frame(height: 220)
        .padding(.trailing, 20)
        .padding(.vertical, 20)
    }

    var body: some View {
        VStack {
            Spacer()
            chart
        }
    }
}

extension D3Beeswarm {
    static func weights() -> [Weight] {
        let csv = try! NamedCSV(url: Bundle.main.url(forResource: "cars-2", withExtension: "csv")!)
        let weights = csv.rows.map {
            Weight(weight: Double($0["Weight_in_lbs"]!)!)
        }.sorted { w1, w2 in
            w1.weight < w2.weight
        }

        return weights
    }

    static var sample: Self {
        D3Beeswarm(weights: weights())
    }
}

struct D3Beeswarm_Previews: PreviewProvider {
    static var previews: some View {
        D3Beeswarm.sample
            .frame(width: 640, height: 400)
    }
}

