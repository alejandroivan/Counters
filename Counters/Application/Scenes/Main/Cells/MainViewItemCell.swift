import UIKit

final class MainViewItemCell: UITableViewCell {

    // MARK: - Public properties

    var viewData: Item? {
        didSet {
            guard viewData != oldValue, viewData != nil else { return }
            updateContent()
        }
    }

    // MARK: - Private properties

    private let containerView = UIView()
    private let counterLabel = UILabel()
    private let verticalSeparator = UIView()
    private let titleLabel = UILabel()
    private let counterStepper = UIStepper()

    // MARK: - Constants

    private struct Constants {
        struct ContainerView {
            static let insets = UIEdgeInsets(top: 15, left: 12, bottom: 0, right: 12)
//            static let backgroundColor = UIColor.counters.cardBackground
            static let backgroundColor = UIColor.counters.green
            static let cornerRadius: CGFloat = 8
        }

        struct CounterLabel {
            static let font = UIFont.systemFont(ofSize: 24, weight: .regular)
            static let textColor = UIColor.counters.accent
            static let insets = UIEdgeInsets(top: 16, left: 10, bottom: 10, right: 10)
        }
    }

    // MARK: - Initialization

    convenience init(
        item: Item
    ) {
        self.init(frame: .zero)
        self.viewData = item
        configureView()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    // MARK: - Configuration

    private func configureView() {
        backgroundColor = .clear
        selectionStyle = .none
        configureContainerView()
        configureCounterLabel()
        configureVerticalSeparator()
        configureTitleLabel()
        configureCounterStepper()
    }

    private func configureContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        containerView.backgroundColor = Constants.ContainerView.backgroundColor
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = Constants.ContainerView.cornerRadius

        let insets = Constants.ContainerView.insets
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right)
        ])
    }

    private func configureCounterLabel() {
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(counterLabel)

        counterLabel.font = Constants.CounterLabel.font
        counterLabel.textColor = Constants.CounterLabel.textColor

        let insets = Constants.CounterLabel.insets
        NSLayoutConstraint.activate([
            counterLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: insets.top),
            counterLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -insets.bottom),
            counterLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: insets.left),
            counterLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -insets.right),
            counterLabel.heightAnchor.constraint(equalToConstant: 10),
        ])
    }

    private func configureVerticalSeparator() {}

    private func configureTitleLabel() {}

    private func configureCounterStepper() {}

    // MARK: - Content

    private func updateContent() {
        guard let viewData = viewData else { return }
        print("Content updated: \(viewData)")
    }
}
