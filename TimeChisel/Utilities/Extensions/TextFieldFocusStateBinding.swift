//
//  TextFieldFocusStateBinding.swift
//  TimeChisel
//
//  Created by Karsten Krause on 20.06.24.
//

import Foundation
import SwiftUI

extension View {
    func focusStateSync<T: Equatable>(_ binding: Binding<T>, with focusState: FocusState<T>) -> some View {
        self
            .onChange(of: binding.wrappedValue) { oldValue, newValue in
                focusState.wrappedValue = newValue
            }
            .onChange(of: focusState.wrappedValue) { oldValue, newValue in
                binding.wrappedValue = newValue
            }
    }
}

