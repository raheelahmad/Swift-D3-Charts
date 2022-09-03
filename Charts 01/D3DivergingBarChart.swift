//
//  D3DivergingBarChart.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 9/1/22.
//

import SwiftUI
import Charts
import SwiftCSV

struct D3DivergingBarChart: View {
    enum Style: String, CaseIterable, Identifiable {
        case absolute, relative
        var id: String { rawValue }

        var title: String {
            switch self {
            case .absolute: return "Absolute"
            case .relative: return "Relative"
            }
        }
    }

    let populations: [StatePopulation]
    @State private var style: Style = .absolute

    private func startX(_ pop: StatePopulation) -> Double {
        switch style {
        case .absolute: return pop.startX
        case .relative: return pop.startXPct
        }
    }

    private func endX(_ pop: StatePopulation) -> Double {
        switch style {
        case .absolute: return pop.endX
        case .relative: return pop.endXPct
        }
    }

    private func foregroundCol(_ pop: StatePopulation) -> Color {
        pop.increased ? Color(hex: "76a7cb") : Color(hex: "e18f6a")
    }

    private func leadingAnnotationText(_ pop: StatePopulation) -> String {
        if pop.increased {
            return pop.state
        } else {
            return style == .absolute ? pop.increase.formatted() : pop.increasePct.formatted()
        }
    }

    private func trailingAnnotationText(_ pop: StatePopulation) -> String {
        if pop.increased {
            return style == .absolute ? pop.increase.formatted(PositiveSignDoubleStyle()) : pop.increasePct.formatted(PositiveSignDoubleStyle())
        } else {
            return pop.state
        }
    }

    private var chart: some View {
        Chart {
            ForEach(populations) { pop in
                RectangleMark(
                    xStart: .value("Start", startX(pop)),
                    xEnd: .value("End", endX(pop)),
                    y: .value("State", pop.state),
                    height: 20
                )
                .foregroundStyle(foregroundCol(pop))
                .annotation(position: .leading, alignment: .center, spacing: 10) {
                    Text(leadingAnnotationText(pop))
                        .font(.footnote)
                        .foregroundColor(pop.increased ? .secondary : .primary)
                }
                .annotation(position: .trailing, alignment: .center, spacing: 10) {
                    Text(trailingAnnotationText(pop))
                        .font(.footnote)
                        .foregroundColor(pop.increased ? .primary : .secondary)
                }
            }
        }
        .chartYAxis(.hidden)
        .chartXScale(domain: style == .absolute ? -500000.0...4000000.0 : -16.0...18.0)
        .chartXAxis {
            AxisMarks(
                preset: .aligned,
                position: .top,
                values: .stride(by: style == .absolute ? 5_000_00 : 2)
            ) { value in
                AxisValueLabel(format: PositiveSignDoubleStyle())
                AxisTick(
                    centered: false,
                    length: 9,
                    stroke: .init(lineWidth: 1)
                )
                AxisGridLine()
            }
        }
        .chartXAxisLabel {
            HStack(spacing: 4) {
                Text("← decrease · Change in population · increase →")
                Spacer()
            }.offset(x: -10, y: -10)
        }
        .padding(.horizontal, 80)
        .padding(.vertical, 10)
    }

    private var picker: some View {
        Picker("Change", selection: $style) {
            ForEach(Style.allCases) { style in
                Text(style.title).tag(style)
            }
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            picker
            ScrollView {
                chart
                    .frame(height: 1200)
            }
        }
        .padding()
    }
}

struct StatePopulation: Identifiable {
    let id: UUID
    let state: String
    let ten: Double
    let nineteen: Double

    var increased: Bool {
        increase > 0
    }

    var increase: Double {
        nineteen - ten
    }

    var increasePct: Double {
        (increase / ten) * 100
    }

    var startX: Double {
        increased ? 0 : increase // if it increased we are starting from "0", otherwise from a negative position
    }

    var endX: Double {
        increased ? increase : 0
    }

    var startXPct: Double {
        (startX / ten) * 100
    }

    var endXPct: Double {
        (endX / ten) * 100
    }
}

extension D3DivergingBarChart {
    static var data: [StatePopulation] {
        let csv = try! NamedCSV(url: Bundle.main.url(forResource: "state-population-2010-2019", withExtension: "csv")!)
        let rows: [StatePopulation] = csv.rows.compactMap { row in
            guard
                let state = row["State"],
                let ten = row["2010"].flatMap(Double.init),
                let nineteen = row["2019"].flatMap(Double.init)
            else {
                return nil

            }
            return StatePopulation(id: UUID(), state: state, ten: ten, nineteen: nineteen)
        }

        return rows
            .sorted { pop1, pop2 in
                (pop1.nineteen - pop1.ten) < (pop2.nineteen - pop2.ten)
            }
    }
    static var sample: Self {
        D3DivergingBarChart(populations: data)
    }
}

fileprivate struct PositiveSignDoubleStyle: FormatStyle {
  typealias FormatInput = Double
  typealias FormatOutput = String

  func format(_ value: Double) -> String {
      (value > 0 ? "+" : "") + value.formatted()
  }
}

struct D3DivergingBarChart_Previews: PreviewProvider {
    static var previews: some View {
        D3DivergingBarChart.sample
            .frame(width: 840, height: 700)
    }
}
