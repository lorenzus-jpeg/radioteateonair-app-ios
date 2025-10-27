//
//  ModalType.swift
//  Radio Teate On Air
//
//  Created by Lorenzo Cugini on 19/10/25.
//

import Foundation

enum ModalType: Identifiable {
    case schedule
    case programs
    case whoWeAre
    
    var id: String {
        switch self {
        case .schedule: return "schedule"
        case .programs: return "programs"
        case .whoWeAre: return "whoWeAre"
        }
    }
}
