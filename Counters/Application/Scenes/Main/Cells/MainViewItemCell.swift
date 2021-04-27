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
    private let verticalSeparator = UIView()
    private let counterLabel = UILabel()
    private let titleLabel = UILabel()
    private let counterStepper = UIStepper()

    // MARK: - Constants

    private struct Constants {
        struct ContainerView {
            static let insets = UIEdgeInsets(top: 15, left: 12, bottom: 0, right: 12)
            static let backgroundColor = UIColor.counters.cardBackground
            static let cornerRadius: CGFloat = 8
        }

        struct VerticalSeparator {
            static let backgroundColor = UIColor.counters.background
            static let leftSpacing: CGFloat = 60
            static let width: CGFloat = 2
        }

        struct CounterLabel {
            static let font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            static let textColor = UIColor.counters.accent
            static let textAlignment: NSTextAlignment = .right
            static let insets = UIEdgeInsets(top: 15, left: 10, bottom: 16, right: 10)
        }

        struct TitleLabel {
            static let font = UIFont.systemFont(ofSize: 17, weight: .regular)
            static let textColor = UIColor.counters.primaryText
            static let numberOfLines: Int = 0
            static let topSpacing: CGFloat = 16
            static let leftSpacing: CGFloat = 10
            static let rightSpacing: CGFloat = 14
            static let minimumHeight: CGFloat = 20
        }

        struct Stepper {
            static let size: CGSize = CGSize(width: 100, height: 30)
            static let topSpacing: CGFloat = 16
            static let rightSpacing: CGFloat = 14
            static let bottomSpacing: CGFloat = 16
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
        configureVerticalSeparator()
        configureCounterLabel()
        configureTitleLabel()
        configureCounterStepper()
        updateContent()
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

    private func configureVerticalSeparator() {
        verticalSeparator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(verticalSeparator)

        verticalSeparator.backgroundColor = Constants.VerticalSeparator.backgroundColor

        NSLayoutConstraint.activate([
            verticalSeparator.topAnchor.constraint(equalTo: containerView.topAnchor),
            verticalSeparator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            verticalSeparator.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.VerticalSeparator.leftSpacing
            ),
            verticalSeparator.widthAnchor.constraint(equalToConstant: Constants.VerticalSeparator.width)
        ])
    }

    private func configureCounterLabel() {
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(counterLabel)

        counterLabel.font = Constants.CounterLabel.font
        counterLabel.textColor = Constants.CounterLabel.textColor
        counterLabel.textAlignment = Constants.CounterLabel.textAlignment

        let insets = Constants.CounterLabel.insets
        NSLayoutConstraint.activate([
            counterLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: insets.top),
            counterLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -insets.bottom),
            counterLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: insets.left),
            counterLabel.trailingAnchor.constraint(equalTo: verticalSeparator.leadingAnchor, constant: -insets.right)
        ])
    }

    private func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        titleLabel.font = Constants.TitleLabel.font
        titleLabel.textColor = Constants.TitleLabel.textColor
        titleLabel.numberOfLines = Constants.TitleLabel.numberOfLines

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Constants.TitleLabel.topSpacing
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: verticalSeparator.trailingAnchor,
                constant: Constants.TitleLabel.leftSpacing
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Constants.TitleLabel.rightSpacing
            ),
            titleLabel.heightAnchor.constraint(equalToConstant: Constants.TitleLabel.minimumHeight)
        ])
    }

    private func configureCounterStepper() {
        counterStepper.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(counterStepper)

        // Customize...

        NSLayoutConstraint.activate([
            counterStepper.widthAnchor.constraint(equalToConstant: Constants.Stepper.size.width),
            counterStepper.heightAnchor.constraint(equalToConstant: Constants.Stepper.size.height),
            counterStepper.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Constants.Stepper.topSpacing
            ),
            counterStepper.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Constants.Stepper.rightSpacing
            ),
            counterStepper.bottomAnchor.constraint(
                lessThanOrEqualTo: containerView.bottomAnchor,
                constant: -Constants.Stepper.bottomSpacing
            )
        ])
    }

    // MARK: - Content

    private func updateContent() {
        guard let viewData = viewData else { return }
        counterLabel.text = String(viewData.count)
        titleLabel.text = viewData.title
        print("Content updated: \(viewData)")
    }
}
