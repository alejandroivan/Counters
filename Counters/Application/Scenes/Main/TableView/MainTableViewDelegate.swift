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
        guard tableView.isEditing else { return }
        presenter?.updateBottomBarButtonsState()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else { return }
        presenter?.updateBottomBarButtonsState()
    }
}

extension MainTableViewDelegate: MainViewItemCellDelegate {

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
