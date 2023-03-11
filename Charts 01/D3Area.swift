//
//  D3Area.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 8/25/22.
//

import SwiftUI
import SwiftCSV
import Charts

struct DailyClose: Identifiable {
    let day: Date
    let value: Double

    var id: Date { day }
}

// ---

/// Recreating the [D3 Area Chart](https://observablehq.com/@d3/area-chart?collection=@d3/charts) notebook.
struct D3Area: View {
    let data: [DailyClose]
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

    private func textForDate(index: Int, total: Int) -> String {
        let dataIndex = data.count/total * (index + 1)
        guard dataIndex < data.count else { return "" }
        let date = data[dataIndex].day
        let isJan = Calendar.current.dateComponents([.month], from: date).month == 1
        return isJan ? yearFM.string(from: date) : monthFM.string(from: date)
    }

    private var chart: some View {
        Chart(data) { item in
            AreaMark(x: .value("Day", item.day), yStart: .value("Bottom", 0), yEnd: .value("Close", item.value))
                .foregroundStyle(Color.steelBlue)
        }
        .chartXAxis {
            AxisMarks(preset: .aligned, position: .bottom, values: .automatic(desiredCount: 16)) { value in
                AxisValueLabel(content: {
                    Text(textForDate(index: value.index, total: value.count))
                })
                    .font(.caption2)
                AxisTick(centered: false, length: 9, stroke: .init(lineWidth: 1))
            }
        }
        .d3YAxis
        .d3YAxisLabel("Daily Close ($)")
    }

    private var link: some View {
        D3LinkView(url: URL(string: "https://observablehq.com/@d3/area-chart?collection=@d3/charts")!)
    }

    var body: some View {
        VStack {
            link
            chart
        }
            .padding()
    }
}

extension D3Area {
    static var sample: Self {
        D3Area(data: aaplCSV())
    }
}

// ---

func aaplCSV() -> [DailyClose] {
    let fm = DateFormatter()
    fm.dateFormat = "YYYY-MM-dd"
    let csv = try! NamedCSV(url: Bundle.main.url(forResource: "aapl", withExtension: "csv")!)
    let data = csv.rows.map { row in
        let day = fm.date(from: row["date"]!)!
        let close = Double(row["close"]!)!
        return DailyClose(day: day, value: close)
    }
    return data
}


struct D3Area_Previews: PreviewProvider {
    static var previews: some View {
        D3Area(data: aaplCSV())
            .frame(width: 1000)
    }
}
