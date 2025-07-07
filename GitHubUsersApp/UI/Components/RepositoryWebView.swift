//
//  RepositoryWebView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI
import WebKit

struct RepositoryWebView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var hasError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                WebViewRepresentable(
                    url: url,
                    isLoading: $isLoading,
                    hasError: $hasError
                )
                
                if isLoading {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Loading repository...")
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DesignSystem.Colors.background)
                }
                
                if hasError {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(DesignSystem.Colors.error)
                        
                        Text("Failed to load repository")
                            .font(DesignSystem.Typography.title2)
                            .foregroundColor(DesignSystem.Colors.githubText)
                        
                        Text("Please check your internet connection and try again.")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            hasError = false
                            isLoading = true
                        }
                        .primaryButtonStyle()
                    }
                    .padding(DesignSystem.Spacing.xl)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DesignSystem.Colors.background)
                }
            }
            .navigationTitle("Repository")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIApplication.shared.open(url)
                    } label: {
                        Image(systemName: "safari")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var hasError: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only load if the URL has changed or if there's no current URL
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebViewRepresentable
        
        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.hasError = false
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            // Don't set error for cancelled requests (code -999)
            if (error as NSError).code != NSURLErrorCancelled {
                parent.isLoading = false
                parent.hasError = true
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            // Don't set error for cancelled requests (code -999)
            if (error as NSError).code != NSURLErrorCancelled {
                parent.isLoading = false
                parent.hasError = true
            }
        }
    }
}

#Preview {
    RepositoryWebView(url: URL(string: "https://github.com/octocat/Hello-World")!)
} 
