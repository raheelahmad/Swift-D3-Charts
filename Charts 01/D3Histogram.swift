//
//  D3Histogram.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 8/21/22.
//

import SwiftUI
import Charts

extension View {
    var d3YAxis: some View {
        chartYAxis {
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
    }

    func d3YAxisLabel(_ text: String) -> some View {
        chartYAxisLabel {
            HStack(spacing: 4) {
                Text("↑")
                Text(text)
            }.offset(x: -10, y: -10)
        }
    }
}

/// Recreating the two Histograms from the introductory [D3-Charts](https://observablehq.com/@d3/charts?collection=@d3/charts) notebook.
struct D3Histogram: View {
    enum Style: String, CaseIterable, Identifiable {
        case simple, wide
        var id: String { rawValue }
    }

    let binnedData: [(ChartBinRange<Double>, Int)]
    @Environment(\.colorScheme) var colorScheme
    @State private var style: Style = .simple

    private var markColor: Color {
        switch style {
        case .simple: return colorScheme == .dark ? .white : .black
        case .wide: return Color.steelBlue
        }
    }

    private var xAxisStride: Double {
        switch style {
        case .simple: return 0.1
        case .wide: return 0.05
        }
    }

    private var width: Double {
        switch style {
        case .simple: return 500
        case .wide: return 1100
        }
    }

    private var chart: some View {
        Chart(Array(binnedData.enumerated()), id: \.offset) { (_, rangeAndFreq) in
            BarMark(
                x: .value("Range", rangeAndFreq.0),
                y: .value("Frequency", rangeAndFreq.1)
            )
            .cornerRadius(0)
            .foregroundStyle(markColor)
        }
        .chartYScale(domain: 0.0...110.0)
        .d3YAxisLabel("Frequency")
        .d3YAxis
        .chartXScale(domain: 0...1.0)
        .chartXAxis {
            AxisMarks(preset: .aligned, position: .bottom, values: .stride(by: xAxisStride)) { value in
                AxisValueLabel()
                    .font(.caption2)
                AxisTick(centered: true, length: 9, stroke: .init(lineWidth: 1))
            }
        }
        .frame(width: width)
        .padding(.trailing, 20)
        .padding(.vertical, 20)
    }

    private var stylePicker: some View {
        Picker(selection: $style) {
            ForEach(Style.allCases) {
                Text($0.rawValue)
                    .tag($0)
            }
        } label: {
            Text("Style")
        }.pickerStyle(.segmented)
            .fixedSize()

    }

    var body: some View {
        VStack(alignment: .leading, spacing: 21) {
            chart
            Divider()
            stylePicker
        }
        .padding()
    }
}

extension D3Histogram {
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

    static var sample: Self {
        D3Histogram(binnedData: bins())
    }
}

struct HistogramWithNumberBins_Previews: PreviewProvider {
    static var previews: some View {
        D3Histogram.sample
            .frame(width: 640, height: 400)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    static var steelBlue: Color {
        Color(hex: "4682b4")
    }
}
