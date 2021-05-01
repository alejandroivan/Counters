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

        let realIndex: Int

        if presenter?.isFiltering == true {
            if let filteredItem = presenter?.filteredItems[indexPath.row] {
                realIndex = presenter?.items.firstIndex { item in item.identifier == filteredItem.identifier } ?? 0
            } else {
                realIndex = 0
            }
        } else {
            realIndex = indexPath.row
        }

        switch countAction {
        case .increment:
            presenter?.incrementItem(at: realIndex)
        case .decrement:
            presenter?.decrementItem(at: realIndex)
        }
    }
}
