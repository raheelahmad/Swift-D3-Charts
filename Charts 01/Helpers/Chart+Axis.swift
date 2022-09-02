//
//  Chart+Axis.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 9/1/22.
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

