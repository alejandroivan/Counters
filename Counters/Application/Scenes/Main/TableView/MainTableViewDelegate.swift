import UIKit

final class MainTableViewDelegate: NSObject, UITableViewDelegate {
    weak var presenter: MainPresenter?

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension MainTableViewDelegate: MainViewItemCellDelegate {

    // TODO: We still need a reference to the TableView here!
    // Using the tablView and the cell, we can get the indexPath of the cell
    // and get the item from there.
    func mainViewCell(_ cell: MainViewItemCell, countAction: MainViewItemAction) {
        switch countAction {
        case .increment:
            print("Incrementing!")
        case .decrement:
            print("Decrementing!")
        }
    }
}
