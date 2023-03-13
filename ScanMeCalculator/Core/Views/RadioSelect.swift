//
//  RadioSelect.swift
//  KalkulatorSaham
//
//  Created by Alfin on 06/03/23.
//

import SwiftUI

struct RadioSelect<T>: View where T: Equatable {
    var title: String? = nil
    var keys: [String]
    var values: [T]
    
    @Binding var selected: T
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = title {
                Text(title).fontWeight(.bold)
                Spacer()
                    .frame(height: 15)
            }
            
            ForEach(0..<keys.count, id: \.self) { index in
                let isSelected = values[index] == selected
                
                HStack(spacing: 20) {
                    Image(systemName: isSelected ? "record.circle" : "circle")
                        .foregroundColor(isSelected ? .accentColor : .secondaryLabel)
                    
                    Text(keys[index])
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                .contentShape(Rectangle())
                .onTapGesture {
                    self.selected = values[index]
                }
            }
        }
    }
}
