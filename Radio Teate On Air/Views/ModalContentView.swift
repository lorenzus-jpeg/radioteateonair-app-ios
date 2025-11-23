
//
//  ModalContentView.swift
//  @author lorenzus-jpeg
//
import SwiftUI
struct ModalContentView: View {
    let modalType: ModalType
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                
                Group {
                    switch modalType {
                    case .schedule:
                        ScheduleModalView()
                    case .programs:
                        ProgramsModalView()
                    case .whoWeAre:
                        WhoWeAreModalView()
                    case .settings:
                        SettingsModalView()
                    }
                }
            }
        }
    }
}
