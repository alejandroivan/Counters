import UIKit

public extension String {

    @discardableResult
    func sendToShareActivity(
        completion: UIActivityViewController.CompletionWithItemsHandler? = nil
    ) -> Bool {
        let activityController = UIActivityViewController(
            activityItems: [self],
            applicationActivities: nil
        )
        activityController.excludedActivityTypes = [
            .saveToCameraRoll
        ]
        activityController.completionWithItemsHandler = completion

        guard
            let window = UIApplication.shared.windows.last(where: { $0.isKeyWindow }),
            let rootViewController = window.rootViewController?.presentedViewController
        else {
            #if DEBUG
            print("Couldn't share the string \"\(self)\".")
            #endif
            return false
        }

        rootViewController.present(activityController, animated: true, completion: nil)
        return true
    }
}

public extension Array where Element == String {

    @discardableResult
    func sendToShareActivity(
        completion: UIActivityViewController.CompletionWithItemsHandler? = nil
    ) -> Bool {
        let shareString = reduce(GlobalConstants.empty) { result, item in
            "\(result)\n\(item)".trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return shareString.sendToShareActivity(completion: completion)
    }
}
