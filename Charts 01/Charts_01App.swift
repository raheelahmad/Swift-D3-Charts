//
//  Charts_01App.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 8/20/22.
//

import SwiftUI

enum Example: String, View, CaseIterable, Identifiable {
    case histogram, area, bandChart, areaDifference

    var id: String {
        rawValue
    }

    var body: some View {
        switch self {
        case .histogram:
            D3Histogram.sample
        case .area:
            D3Area.sample
        case .bandChart:
            D3BandChart.sample
        case .areaDifference:
            D3DifferenceChart.sample
        }
    }
}

@main
struct Charts_01App: App {
    @State private var example = Example.area
    var body: some Scene {
        WindowGroup {
            HSplitView {
                List(selection: $example) {
                    Section {
                        ForEach(Example.allCases) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    } header: {
                        Text("Examples")
                    }
                }
                .listStyle(.sidebar)
                .frame(width: 220)

                example
            }
        }
    }
}
