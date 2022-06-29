//
//  HealthCategoryCellView.swift
//  UIHostingConfigurationWithApple
//
//  Created by JeongminKim on 2022/06/30.
//

import SwiftUI

struct HealthCategoryProperties {
    var name: String
    var systemImageName: String
    var color: Color
}

enum HealthCategory: CaseIterable {
    case activity
    case bodyMeasurement
    case hearing
    case heart
    
    var properties: HealthCategoryProperties {
        switch self {
        case .activity:
            return .init(name: "Activity", systemImageName: "flame.fill", color: .orange)
        case .bodyMeasurement:
            return .init(name: "Body Measurements", systemImageName: "figure.stand", color: .purple)
        case .hearing:
            return .init(name: "Hearing", systemImageName: "ear", color: .blue)
        case .heart:
            return .init(name: "Heart", systemImageName: "heart.fill", color: .blue)
        }
    }
}

struct HealthCategoryCellView: View {
    var healthCategory: HealthCategory
    private var properties: HealthCategoryProperties {
        healthCategory.properties
    }
    var body: some View {
        HStack {
            Label(properties.name, systemImage: properties.systemImageName)
                .foregroundStyle(properties.color)
                .font(.system(.headline, weight: .bold))
            
            Spacer()
        }
    }
}
