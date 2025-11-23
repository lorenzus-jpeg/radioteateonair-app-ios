//
//  ModalType.swift
//  @author lorenzus-jpeg
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
