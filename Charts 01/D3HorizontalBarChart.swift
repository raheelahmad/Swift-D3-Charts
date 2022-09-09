//
//  D3HorizontalBarChart.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 9/5/22.
//

import Foundation
import AppKit
import SwiftUI
import Charts
import SwiftCSV

struct D3HorizontalBarChart: View {
    @Environment(\.colorScheme) var colorScheme
    fileprivate let alphabets: [AlphabetFrequency]

    private var chart: some View {
        Chart(alphabets) { alpha in
            RectangleMark(
                xStart: .value("Start", 0),
                xEnd: .value("Frequency", alpha.frequency),
                y: .value("Letter", alpha.letter),
                height: 24
            )
            .annotation(
                position: .trailing,
                alignment: .center,
                // this could be calculated based on ChartProxy and the text width
                spacing: alpha.isTiny ? 5 : -30
            ) {
                Text(alpha.frequency.formatted(ShortPercentageDoubleStyle()))
                    .font(.footnote)
                    .foregroundColor(alpha.isTiny && colorScheme == .light ? .black : .white)
            }
            .foregroundStyle(Color.steelBlue)
        }
        .chartYAxisLabel(position: .topTrailing, spacing: 30) {
            Text("Frequency →")
                .offset(x: -40)
        }
        .chartXScale(domain: 0...0.13)
        .chartXAxis {
            AxisMarks(
                preset: .aligned,
                position: .top,
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
                AxisTick(centered: true, length: 8, stroke: .init(lineWidth: 0.7))
            }

        }
    }

    var body: some View {
        chart
            .padding(.horizontal)
            .padding(.vertical)
    }
}

// ---

extension D3HorizontalBarChart {
    static var sample: D3HorizontalBarChart {
        D3HorizontalBarChart(alphabets: alphabetsCSV())
    }
}

struct D3HorizontalBarChart_Previews: PreviewProvider {
    static var previews: some View {
        D3HorizontalBarChart.sample
            .frame(width: 1000, height: 800)
    }
}

fileprivate struct ShortPercentageDoubleStyle: FormatStyle {
  typealias FormatInput = Double
  typealias FormatOutput = String

  func format(_ value: Double) -> String {
      String(format: "%0.1f", value * 100) + "%"
  }
}

// ---

struct AlphabetFrequency: Identifiable {
    let letter: String
    let frequency: Double

    var id: String { letter }

    var isTiny: Bool { frequency < 0.01 }
}

func alphabetsCSV() -> [AlphabetFrequency] {
    let csv = try! NamedCSV(url: Bundle.main.url(forResource: "alphabet", withExtension: "csv")!)
    let rows: [AlphabetFrequency] = csv.rows.compactMap { row in
        guard
            let letter = row["letter"],
            let frequency = row["frequency"].flatMap(Double.init)
        else { return nil }
        return AlphabetFrequency(letter: letter, frequency: frequency)
    }

    return rows.sorted { a1, a2 in
        a1.frequency > a2.frequency
    }
}
