//
//  ContentView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("GitHub Users App")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Project Foundation")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
} 
