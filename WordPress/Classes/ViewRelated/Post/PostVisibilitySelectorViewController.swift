import UIKit

@objc class PostVisibilitySelectorViewController: SettingsSelectionViewController {
    /// The post to change the visibility
    private var post: AbstractPost!

    /// A completion block that is called after the user select an option
    @objc var completion: (() -> Void)?

    // MARK: - Constructors

    @objc init(_ post: AbstractPost) {
        self.post = post

        let titles: NSArray = [
            NSLocalizedString("Public", comment: "Privacy setting for posts set to 'Public' (default). Should be the same as in core WP."),
            NSLocalizedString("Password protected", comment: "Privacy setting for posts set to 'Password protected'. Should be the same as in core WP."),
            NSLocalizedString("Private", comment: "Privacy setting for posts set to 'Private'. Should be the same as in core WP.")
        ]

        let visiblityDict: [AnyHashable: Any] = [
            "DefaultValue": NSLocalizedString("Public", comment: "Privacy setting for posts set to 'Public' (default). Should be the same as in core WP."),
            "Title": NSLocalizedString("Visibility", comment: "Visibility label"),
            "Titles": titles,
            "Values": titles,
            "CurrentValue": post.titleForVisibility
        ]

        super.init(dictionary: visiblityDict)

        onItemSelected = { visibility in
            guard let visibility = visibility as? String,
                !post.isFault, post.managedObjectContext != nil else {
                return
            }

            if visibility == AbstractPost.privateLabel {
                post.status = .publishPrivate
                post.password = nil
            } else {
                if post.status == .publishPrivate {
                    if post.original?.status == .publishPrivate {
                        post.status = .publish
                    } else {
                        // restore the original status
                        post.status = post.original?.status
                    }
                }

                if visibility == AbstractPost.passwordProtectedLabel {
                    var password = ""

                    assert(post.original != nil,
                           "We're expecting to have a reference to the original post here.")
                    assert(!post.original!.isFault,
                           "We're expecting to have a reference to the original post here.")
                    assert(post.original!.managedObjectContext != nil,
                           "The original post's MOC should not be nil here.")

                    if let originalPassword = post.original?.password {
                        password = originalPassword
                    }
                    post.password = password
                } else {
                    post.password = nil
                }
            }

            self.completion?()

        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init!(style: UITableView.Style, andDictionary dictionary: [AnyHashable: Any]!) {
        super.init(style: style, andDictionary: dictionary)
    }

    override init(style: UITableView.Style) {
        super.init(style: style)
    }
}

// MARK: - Abstract Post private extension

extension AbstractPost {
    static let passwordProtectedLabel = NSLocalizedString("Password protected", comment: "Privacy setting for posts set to 'Password protected'. Should be the same as in core WP.")
    static let privateLabel = NSLocalizedString("Private", comment: "Privacy setting for posts set to 'Private'. Should be the same as in core WP.")
    static let publicLabel = NSLocalizedString("Public", comment: "Privacy setting for posts set to 'Public' (default). Should be the same as in core WP.")

    @objc var titleForVisibility: String {
        if password != nil {
            return AbstractPost.passwordProtectedLabel
        } else if status == .publishPrivate {
            return AbstractPost.privateLabel
        }

        return AbstractPost.publicLabel
    }
}
