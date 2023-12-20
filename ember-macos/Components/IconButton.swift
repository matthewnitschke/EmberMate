//
//  IconButton.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/19/23.
//

import Foundation
import SwiftUI

struct IconButton: View {
    var headerText: String?
    var footerText: String
    var icon: String
    var isSelected: Bool
    var onSelect: () -> Void
    
    var body: some View {
        Button(action: {
            onSelect()
        }) {
            VStack {
                if headerText != nil {
                    Text(headerText ?? "")
                        .font(.caption)
                }

                
                Spacer()
                Image(systemName: icon)
                    .font(.largeTitle)
                Spacer()
                
                Text(footerText)
                    .font(.caption)
            }
            .padding(10)
            .frame(width: 90, height: 90)
            .background(Color.black.opacity(isSelected ? 0.6 : 0.29))
        }
        .buttonStyle(.plain)
        .cornerRadius(9)
    }
}
