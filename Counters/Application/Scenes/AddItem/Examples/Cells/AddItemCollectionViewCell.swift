import UIKit

final class AddItemCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants

    private struct Constants {
        static let leftSpacing: CGFloat = 20
        static let rightSpacing: CGFloat = 20
        static let font = UIFont.systemFont(ofSize: 17, weight: .regular)

        static let backgroundColor = UIColor.counters.cardBackground
        static let highlightedBackgroundColor = UIColor.counters.accent
        static let textColor = UIColor.counters.primaryText
        static let highlightedTextColor = UIColor.counters.buttonText
    }

    // MARK: - Public

    var title: String? {
        didSet {
            label.text = title
            recalculateItemSize()
        }
    }

    public private(set) var itemSize: CGSize = .zero

    // MARK: - Private

    private func recalculateItemSize() {
        let calculatedSize = label.sizeThatFits(CGSize(width: CGFloat.infinity, height: 20))
        var itemWidth = calculatedSize.width
        itemWidth += Constants.leftSpacing + Constants.rightSpacing
        itemSize = CGSize(width: itemWidth, height: calculatedSize.height)
    }

    // MARK: - Subviews

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Overrides

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                contentView.backgroundColor = Constants.highlightedBackgroundColor
                label.textColor = Constants.highlightedTextColor
            } else {
                contentView.backgroundColor = Constants.backgroundColor
                label.textColor = Constants.textColor
            }
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }

    private func configureViews() {
        contentView.backgroundColor = Constants.backgroundColor
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8

        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leftSpacing),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.rightSpacing)
        ])
    }
}
