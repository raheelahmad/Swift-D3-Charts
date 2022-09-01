//
//  D3BandChart.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 8/28/22.
//

import SwiftUI
import Charts
import SwiftCSV

struct D3BandChart: View {
    let temperatures: [TemperatureHighLow]
    private let yearFM: DateFormatter = {
        let fm = DateFormatter()
        fm.dateFormat = "YYYY"
        return fm
    }()
    private let monthFM: DateFormatter = {
        let fm = DateFormatter()
        fm.dateFormat = "MMMM"
        return fm
    }()


    private func textForDate(index: Int, total: Int) -> String? {
        let dataIndex = temperatures.count/total * (index + 1)
        guard dataIndex < temperatures.count else { return nil }
        let date = temperatures[dataIndex].date

        let goodMonths = [1, 4, 7, 10, 13]
        let comps = Calendar.current.dateComponents([.month, .day, .year], from: date)
        let month = comps.month!
        let day = comps.day!

        guard
            day == 1,
            goodMonths.contains(month)
        else { return nil }

        let isJan = month == 1
        return isJan ? yearFM.string(from: date) : monthFM.string(from: date)
    }

    private func hasXAxisDate(index: Int, total: Int) -> Bool {
        textForDate(index: index, total: total) != nil
    }

    private var chart: some View {
        Chart(temperatures) { temp in
            AreaMark(
                x: .value("Date", temp.date),
                yStart: .value("Low", temp.low),
                yEnd: .value("Low", temp.high)
            )
            .interpolationMethod(.stepCenter)
        }
        .chartYAxis {
            AxisMarks(
                preset: .automatic,
                position: .leading,
                values: .automatic(desiredCount: 8)
            ) { value in
                AxisValueLabel()
                    .font(.caption2)
                AxisTick(centered: false, length: 9, stroke: .init(lineWidth: 1))
            }
        }
        .chartYScale(domain: .automatic(includesZero: false))
        .chartXAxis {
            /// We stride by day, and then just pick the start of months as valid ticks in `textForDate()`
            AxisMarks(preset: .aligned, position: .bottom, values: .stride(by: .day)) { value in
                AxisValueLabel {
                    Text(textForDate(index: value.index, total: value.count) ?? "")
                }
                AxisTick(
                    centered: false,
                    length: hasXAxisDate(index: value.index, total: value.count) ? 9 : 0,
                    stroke: .init(lineWidth: 1)
                )
            }
        }
        .d3YAxisLabel("Tempereature (°F)")
        .padding()
    }

    var body: some View {
        chart
    }
}

extension D3BandChart {
    static var sample: Self {
        D3BandChart(temperatures: temperatureCSV())
    }
}

struct TemperatureHighLow: Identifiable {
    let date: Date
    let high: Double
    let low: Double

    var id: Date { date }
}

func temperatureCSV() -> [TemperatureHighLow] {
    let csv = try! NamedCSV(url: Bundle.main.url(forResource: "temperatures", withExtension: "csv")!)
    let fm = DateFormatter()
    fm.calendar = Calendar.current
    fm.timeZone = .gmt
    fm.dateFormat = "YYYY-MM-dd'T'hh:mmZ"
    let rows: [TemperatureHighLow] = csv.rows.compactMap { row in
        guard
            let dateStr = row["date"],
            let date = fm.date(from: dateStr),
            let high = row["high"].flatMap(Double.init),
            let low = row["low"].flatMap(Double.init)
        else { return nil }
        return TemperatureHighLow(date: date, high: high, low: low)
    }

    return rows
}

struct D3BandChart_Previews: PreviewProvider {
    static var previews: some View {
        D3BandChart.sample
            .frame(width: 800)
    }
}
