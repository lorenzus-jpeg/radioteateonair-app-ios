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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Sfondo")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    VStack(spacing: 12) {
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
}

struct BackgroundOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

#Preview {
    SettingsModalView()
}