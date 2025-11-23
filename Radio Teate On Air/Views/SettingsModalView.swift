
//
//  SettingsModalView.swift
//  @author lorenzus-jpeg
//
import SwiftUI

struct SettingsModalView: View {
    @AppStorage("backgroundStyle") var backgroundStyle: String = "onde"
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Sfondo")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                VStack(spacing: 8) {
                    BackgroundOptionRow(
                        title: "Onde",
                        isSelected: backgroundStyle == "onde",
                        action: { backgroundStyle = "onde" }
                    )
                    
                    BackgroundOptionRow(
                        title: "Linee",
                        isSelected: backgroundStyle == "linee",
                        action: { backgroundStyle = "linee" }
                    )
                    
                    BackgroundOptionRow(
                        title: "Picchi",
                        isSelected: backgroundStyle == "picchi",
                        action: { backgroundStyle = "picchi" }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

struct BackgroundOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(6)
        }
    }
}

#Preview {
    SettingsModalView()
}
