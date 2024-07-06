//
//  D3DifferenceChart.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 8/28/22.
//

import SwiftUI
import Charts
import SwiftCSV

struct D3DifferenceChart: View {
    let weather: [WeatherTwoCities]
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
        let dataIndex = weather.count/total * (index + 1)
        guard dataIndex < weather.count else { return "" }
        let date = weather[dataIndex].date
        let isJan = Calendar.current.dateComponents([.month], from: date).month == 1
        return isJan ? yearFM.string(from: date) : monthFM.string(from: date)
    }

    private var chart: some View {
        Chart {
            ForEach(weather) { temp in
                AreaMark(
                    x: .value("date-ny", temp.date),
                    yStart: .value("Start-nyc", temp.sf),
                    yEnd: .value("end-nyc", temp.nyc > temp.sf ? temp.nyc : temp.sf),
                    series: .value("nyc", "nyc")
                )
                .interpolationMethod(.stepCenter)
                .foregroundStyle(Color.blue)
            }
            
            ForEach(weather) { temp in
                // SF
                AreaMark(
                    x: .value("date", temp.date),
                    yStart: .value("Start", temp.nyc),
                    yEnd: .value("SF", temp.sf > temp.nyc ? temp.sf : temp.nyc),
                    series: .value("sf", "sf")
                )
                .interpolationMethod(.stepCenter)
                .foregroundStyle(Color.orange.opacity(0.8))
            }


            ForEach(weather) { temp in
                LineMark(x: .value("a", temp.date), y: .value("m", temp.nyc < temp.sf ? temp.nyc : temp.sf), series: .value("nyc-line", "nyc-line"))
                    .foregroundStyle(Color.primary)
                    .lineStyle(.init(lineWidth: 1.0))
                    .interpolationMethod(.stepCenter)
            }

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
        .chartYScale(domain: 15...90)
        .chartXAxis {
            /// We stride by day, and then just pick the start of months as valid ticks in `textForDate()`
            AxisMarks(preset: .aligned, position: .bottom, values: .stride(by: .month)) { value in
                AxisValueLabel {
                    Text(textForDate(index: value.index, total: value.count))
                }
                AxisTick(
                    centered: false,
                    length: 9,
                    stroke: .init(lineWidth: 1)
                )
            }
        }
        .d3YAxisLabel("Tempereature (°F)")
        .padding()
    }

    private var link: some View {
        D3LinkView(url: URL(string: "https://observablehq.com/@d3/difference-chart?collection=@d3/charts")!)
    }

    var body: some View {
        VStack {
            link
            chart
        }.padding()
    }
}

extension D3DifferenceChart {
    static var sample: Self {
        D3DifferenceChart(weather: weatherCSV())
    }
}

struct WeatherTwoCities: Identifiable {
    let date: Date
    let nyc: Double
    let sf: Double

    var id: Date { date }
}


func weatherCSV() -> [WeatherTwoCities] {
    let csv = try! NamedCSV(url: Bundle.main.url(forResource: "weather", withExtension: "csv")!)
    let fm = DateFormatter()
    fm.calendar = Calendar.current
    fm.timeZone = .gmt
    fm.dateFormat = "YYYY-MM-dd"
    let rows: [WeatherTwoCities] = csv.rows.compactMap { row in
        guard
            let dateStr = row["date"],
            let date = fm.date(from: dateStr),
            let nyc = row["New York"].flatMap(Double.init),
            let sf = row["San Francisco"].flatMap(Double.init)
        else {
            return nil

        }
        return WeatherTwoCities(date: date, nyc: nyc, sf: sf)
    }

    return rows
}

struct D3DifferenceChart_Previews: PreviewProvider {
    static var previews: some View {
        D3DifferenceChart.sample
            .frame(width: 800)
    }
}
