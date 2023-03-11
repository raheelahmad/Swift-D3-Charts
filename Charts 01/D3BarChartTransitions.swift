//
//  D3BarChartTransitions.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 9/8/22.
//

import SwiftUI
import Charts

/// Recreating the two Histograms from the introductory [D3-Charts](https://observablehq.com/@d3/charts?collection=@d3/charts) notebook.
fileprivate enum Sorting: String, CaseIterable, Identifiable {
    case alpha, freqDesc, freqAsc
    var id: String { rawValue }

    var title: String {
        switch self {
        case .alpha:
            return "Alphabetical"
        case .freqDesc:
            return "Frequency, Descending"
        case .freqAsc:
            return "Frequency, Ascending"
        }
    }

    mutating func cycle() {
        switch self {
        case .alpha:
            self = .freqDesc
        case .freqDesc:
            self = .freqAsc
        case .freqAsc:
            self = .alpha
        }
    }

    func sort(_ values: inout [AlphabetFrequency]) {
        values.sort { a1, a2 in
            switch self {
            case .alpha:
                return a1.letter < a2.letter
            case .freqDesc:
                return a1.frequency > a2.frequency
            case .freqAsc:
                return a1.frequency < a2.frequency
            }
        }
    }
}

struct D3BarChartTransitions: View {
    @State var alphabets: [AlphabetFrequency]
    @State private var sorting = Sorting.freqDesc

    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()


    @Environment(\.colorScheme) var colorScheme
    private var chart: some View {
        Chart(alphabets) { alpha in
            BarMark(
                x: .value("Alphabet", alpha.letter),
                y: .value("Frequency", alpha.frequency)
            )
            .cornerRadius(0)
            .foregroundStyle(Color.steelBlue.opacity(0.7))
        }
        .d3YAxisLabel("Frequency")
        .chartYScale(domain: 0...0.13)
        .chartYAxis {

                AxisMarks(
                    preset: .aligned,
                    position: .leading,
                    values: .stride(by: 0.01)
                ) { val in
                    AxisValueLabel(format: FloatingPointFormatStyle<Double>.Percent())
                    AxisTick(
                        centered: false,
                        length: 8,
                        stroke: .init(lineWidth: 0.5)
                    )

                    AxisGridLine(centered: true, stroke: .init(lineWidth: 0.5))
                        .foregroundStyle(.gray.opacity(0.2))
                }

        }
        .chartXAxis {
            AxisMarks(preset: .aligned, position: .bottom, values: .automatic) { value in
                AxisValueLabel()
                    .font(.caption2)
                AxisTick(centered: true, length: 9, stroke: .init(lineWidth: 1))
            }
        }
        .padding(.trailing, 20)
        .padding(.vertical, 20)
    }

    private var picker: some View {
        Picker(selection: $sorting) {
            ForEach(Sorting.allCases) { sort in
                Text(sort.title)
                    .tag(sort)
            }
        } label: {
            Text("Sorting")
        }.fixedSize()
    }

    private var link: some View {
        D3LinkView(url: URL(string: "https://observablehq.com/@d3/bar-chart-transitions?collection=@d3/charts")!)
    }

    var body: some View {
        VStack(alignment: .leading) {
            link
            picker
            chart
                .padding()
        }
        .padding()
        .onChange(of: sorting) { sorting in
            withAnimation(.easeOut(duration: 0.75)) {
                sorting.sort(&alphabets)
            }
        }.onReceive(timer) { _ in
            sorting.cycle()
        }
    }
}

extension D3BarChartTransitions {
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
        D3BarChartTransitions(alphabets: alphabetsCSV())
    }
}

struct D3BarChartTransitions_Previews: PreviewProvider {
    static var previews: some View {
        D3BarChartTransitions.sample
            .frame(width: 640, height: 400)
    }
}

