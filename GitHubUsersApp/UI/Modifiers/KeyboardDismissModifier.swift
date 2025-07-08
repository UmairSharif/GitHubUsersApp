//
//  KeyboardDismissModifier.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct KeyboardDismissModifier: ViewModifier {
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Dismiss keyboard
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        onDismiss()
                    }
            )
    }
}

extension View {
    func keyboardDismiss(onDismiss: @escaping () -> Void) -> some View {
        modifier(KeyboardDismissModifier(onDismiss: onDismiss))
    }
} 