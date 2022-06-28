//
//  HostingControllerExample.swift
//  UIHostingConfigurationWithApple
//
//  Created by JeongminKim on 2022/06/28.
//

import UIKit
import SwiftUI

//
/*
 HeartHealthAlert
 - 심장 상태에 대하여 특정 상태가 관찰되었을 때 발생할 얼럿에 쓰일 모델입니다.
 - 이 클래스는 ObservableObject 프로토콜을 채용함으로써 SwiftUI 뷰가 자동적으로 업데이트 될 수 있도록 합니다.
 - @Published 프로퍼티가 변경되면 그에 따라 SwiftUI 뷰가 업데이트 됩니다.
 */
@MainActor
private class HeartHealthAlert: ObservableObject {
    // 얼럿에 보여질 이미지 이름
    @Published var systemImageName: String
    // 얼럿의 제목
    @Published var title: String
    // 얼럿에 대한 설명
    @Published var description: String
    // 얼럿이 보여지고 있는지 여부
    @Published var isEnabled: Bool {
        didSet {
            if oldValue != isEnabled {
                /*
                 
                 */
                NotificationCenter.default.post(name: .heartHealthAlertEnabledDidChange, object: self)
            }
        }
    }
    
    init(systemImageName: String, title: String, description: String, isEnabled: Bool = false) {
        self.systemImageName = systemImageName
        self.title = title
        self.description = description
        self.isEnabled = isEnabled
    }
}

private extension NSNotification.Name {
    static let heartHealthAlertEnabledDidChange = Notification.Name("com.example.UseSwiftUIWithUIKit.heartHealthAlertEnabledDidChange")
}

private extension HeartHealthAlert {
    static func getDefaultAlerts() -> [HeartHealthAlert] {
        [
            HeartHealthAlert(systemImageName: "bolt.heart.fill",
                             title: "Irregular Rhythm",
                             description: "You will be notified when an irregular heart rhythm is detected."),
            HeartHealthAlert(systemImageName: "arrow.up.heart.fill",
                             title: "High Heart Rate",
                             description: "You will be notified when your heart rate rises above normal levels."),
            HeartHealthAlert(systemImageName: "arrow.down.heart.fill",
                             title: "Low Heart Rate",
                             description: "You will be notified when your heart rate falls below normal levels.")
        ]
    }
}

private struct HeartHealthAlertView: View {
    @ObservedObject var alert: HeartHealthAlert
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: alert.systemImageName)
                    .imageScale(.large)
                Text(alert.title)
                Spacer()
                Toggle("Enabled", isOn: $alert.isEnabled)
                    .labelsHidden()
            }
            if alert.isEnabled {
                Text(alert.description)
                    .font(.caption)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemFill))
        )
    }
}

class HostingControllerViewController: UIViewController {
    private var alerts = HeartHealthAlert.getDefaultAlerts()
    
    private var alertsEnabledCount: Int {
        var count = 0
        for alert in alerts where alert.isEnabled {
            count += 1
        }
        return count
    }
    
    private var hostingControllers = [UIHostingController<HeartHealthAlertView>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "심장 건강 경고"
        view.backgroundColor = .systemBackground
        
        // Create the hosting controllers and set up the stack view.
        createHostingControllers()
        setUpStackView()
        
        // Update the UIKit views based on the current state of the alerts.
        updateSummaryLabel()
        updateBarButtonItem()
        
        // Register for notifications when heart health alerts are enabled or disabled, in order to update the UIKit views as necessary.
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(heartHealthAlertDidChange), name: .heartHealthAlertEnabledDidChange, object: nil)
        
    }
    
    private func createHostingControllers() {
        for alert in alerts {
            let alertView = HeartHealthAlertView(alert: alert)
            let hostingController = UIHostingController(rootView: alertView)
            hostingController.sizingOptions = .intrinsicContentSize
            hostingControllers.append(hostingController)
        }
    }
    
    private func setUpStackView() {
        var views: [UIView] = hostingControllers.map { $0.view }
        views.append(summaryLabel)
        
        hostingControllers.forEach { addChild($0) }
        
        let spacing = 10.0
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: spacing)
        ])
        
        // Notify each hosting controller that it has now moved to a new parent view controller
        hostingControllers.forEach { $0.didMove(toParent: self) }
    }
    
    @objc
    private func heartHealthAlertDidChange(_ notification: NSNotification) {
        updateBarButtonItem()
        updateSummaryLabel()
    }
    
    private func updateBarButtonItem() {
        let title: String
        let action: UIAction
        if alertsEnabledCount > 0 {
            title = "Disable All"
            action = UIAction { [unowned self] _ in
                alerts.forEach { $0.isEnabled = false }
            }
        } else {
            title = "Enable All"
            action = UIAction { [unowned self] _ in
                alerts.forEach { $0.isEnabled = true }
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, primaryAction: action)
    }
    
    private lazy var summaryLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private func updateSummaryLabel() {
        let enableCount = alertsEnabledCount
        if enableCount == 0 {
            summaryLabel.text = "No Alerts Enabled"
        } else if enableCount == 1 {
            summaryLabel.text = "\(enableCount.formatted(.number)) Alert Enabled"
        } else {
            summaryLabel.text = "\(enableCount.formatted(.number)) Alerts Enabled"
        }
    }
}
