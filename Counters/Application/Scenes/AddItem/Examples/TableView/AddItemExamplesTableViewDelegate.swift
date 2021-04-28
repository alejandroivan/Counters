import UIKit

final class AddItemExamplesTableViewDelegate: NSObject, UITableViewDelegate {
    weak var showcaseSource: AddItemExamplesTableViewShowcaseProvider?

    private var showcaseKeys: [ItemCategory]? {
        guard let showcase = showcaseSource?.showcase else { return nil }
        let keys = Array(showcase.keys)
        return keys.sorted { $0.rawValue < $1.rawValue }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let key = showcaseKeys?[section].pluralized
        let label = makeLabel()
        label.text = key?.uppercased()
        return containerView(with: label)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        58
    }

    private func containerView(with label: UILabel) -> UIView {
        let containerView = UIView()
        containerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            label.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: 24
            ),
            label.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -24
            ),
        ])

        return containerView
    }

    private func makeLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
