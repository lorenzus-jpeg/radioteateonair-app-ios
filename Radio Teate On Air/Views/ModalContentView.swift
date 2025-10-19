
//
//  ModalContentView.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/10/25.
//

import SwiftUI

struct ModalContentView: View {
    let modalType: ModalType
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with close button
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
                
                // Display the appropriate modal content
                Group {
                    switch modalType {
                    case .schedule:
                        ScheduleModalView()
                    case .programs:
                        ProgramsModalView()
                    case .whoWeAre:
                        WhoWeAreModalView()
                    }
                }
            }
        }
    }
}
