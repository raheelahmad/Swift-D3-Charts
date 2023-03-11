//
//  D3Link.swift
//  Charts 01
//
//  Created by Raheel Ahmad on 3/11/23.
//

import SwiftUI

struct D3LinkView: View {
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack {
                Spacer()
                Text("Original D3 version")
                Image(systemName: "link.circle")
            }.font(.callout)
        }
    }
}
