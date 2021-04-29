import UIKit

final class MainTableViewDelegate: NSObject, UITableViewDelegate {
    weak var presenter: MainPresenter?
    weak var tableView: UITableView?

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.isEditing, let item = presenter?.items[indexPath.row] else { return }
        print("SELECTED ITEM: \(item)")
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.isEditing, let item = presenter?.items[indexPath.row] else { return }
        print("DESELECTED ITEM: \(item)")
    }
}

extension MainTableViewDelegate: MainViewItemCellDelegate {

    // TODO: We still need a reference to the TableView here!
    // Using the tablView and the cell, we can get the indexPath of the cell
    // and get the item from there.
    func mainViewCell(_ cell: MainViewItemCell, countAction: MainViewItemAction) {
        guard let indexPath = tableView?.indexPath(for: cell) else { return }

        switch countAction {
        case .increment:
            presenter?.incrementItem(at: indexPath.row)
        case .decrement:
            presenter?.decrementItem(at: indexPath.row)
        }
    }
}
