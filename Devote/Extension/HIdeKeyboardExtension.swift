//
//  HIdeKeyboardExtension.swift
//  Devote
//
//  Created by Erik Salas on 6/19/21.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
