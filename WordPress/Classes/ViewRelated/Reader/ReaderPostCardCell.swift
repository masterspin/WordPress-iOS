
class ReaderPostCardCell: UITableViewCell {

    // MARK: - Properties

    private let contentStackView = UIStackView()

    private let siteStackView = UIStackView()
    private let siteIconContainerView = UIView()
    private let siteIconImageView = UIImageView()
    private let avatarContainerView = UIView()
    private let avatarImageView = UIImageView()
    private let siteTitleLabel = UILabel()
    private let postDateLabel = UILabel()

    private let postTitleLabel = UILabel()
    private let postSummaryLabel = UILabel()
    private let featuredImageView = CachedAnimatedImageView()
    private let postCountsLabel = UILabel()

    private let controlsStackView = UIStackView()
    private let reblogButton = UIButton()
    private let commentButton = UIButton()
    private let likeButton = UIButton()
    private let fillerView = UIView()
    private let menuButton = UIButton()

    private let separatorView = UIView()

    private lazy var imageLoader = ImageLoader(imageView: featuredImageView)
    private var viewModel: ReaderPostCardCellViewModel? {
        didSet {
            configureLabels()
            configureImages()
            configureButtons()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoader.prepareForReuse()
        resetElements()
        addMissingViews()
        addViewConstraints()
    }

    func configure(with viewModel: ReaderPostCardCellViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Constants

    struct Constants {
        struct ContentStackView {
            static let margins: CGFloat = 16.0
            static let spacing: CGFloat = 8.0
            static let bottomAnchor: CGFloat = 2.0
        }

        struct SiteStackView {
            static let avatarSpacing: CGFloat = -4.0
            static let iconSpacing: CGFloat = 8.0
            static let siteTitleSpacing: CGFloat = 4.0
        }

        struct ControlsStackView {
            static let reblogSpacing: CGFloat = 24.0
            static let commentSpacing: CGFloat = 24.0
            static let likeSpacing: CGFloat = 8.0
            static let trailingConstraint: CGFloat = 10.0
            static let bottomConstraint: CGFloat = -ContentStackView.margins + 10.0
        }

        struct FeaturedImage {
            static let cornerRadius: CGFloat = 5.0
            static let heightAspectMultiplier: CGFloat = 239.0 / 358.0
        }

        static let iconImageSize: CGFloat = 24.0
        static let avatarPlaceholder = UIImage(named: "gravatar")
        static let siteIconPlaceholder = UIImage(named: "post-blavatar-placeholder")
        static let fillerViewHuggingPriority = UILayoutPriority(249.0)
        static let reblogButtonImage = UIImage(named: "icon-reader-reblog")?.withRenderingMode(.alwaysTemplate)
        static let commentButtonImage = UIImage(named: "icon-reader-post-comment")?.withRenderingMode(.alwaysTemplate)
        static let likeButtonImage = UIImage(named: "icon-reader-star-outline")?.withRenderingMode(.alwaysTemplate)
        static let likedButtonImage = UIImage(named: "icon-reader-star-fill")?.withRenderingMode(.alwaysTemplate)
        static let menuButtonImage = UIImage(named: "more-horizontal-mobile")?.withRenderingMode(.alwaysTemplate)
        static let buttonMinimumSize: CGFloat = 44.0
        static let reblogButtonText = NSLocalizedString("reader.post.button.reblog",
                                                        value: "Reblog",
                                                        comment: "Text for the 'Reblog' button on the reader post card cell.")
        static let commentButtonText = NSLocalizedString("reader.post.button.comment",
                                                         value: "Comment",
                                                         comment: "Text for the 'Comment' button on the reader post card cell.")
        static let likeButtonText = NSLocalizedString("reader.post.button.like",
                                                      value: "Like",
                                                      comment: "Text for the 'Like' button on the reader post card cell.")
        static let likedButtonText = NSLocalizedString("reader.post.button.liked",
                                                       value: "Liked",
                                                       comment: "Text for the 'Liked' button on the reader post card cell.")
        static let separatorHeight: CGFloat = 0.5
    }

}

// MARK: - Private methods

private extension ReaderPostCardCell {

    func commonInit() {
        setupViews()
        addViewConstraints()
    }

    // MARK: - View setup

    func setupViews() {
        setupContentView()
        setupContentStackView()

        setupIconImage(avatarImageView,
                       containerView: avatarContainerView,
                       image: Constants.avatarPlaceholder)
        setupIconImage(siteIconImageView,
                       containerView: siteIconContainerView,
                       image: Constants.siteIconPlaceholder)
        setupSiteTitle()
        setupPostDate()
        setupSiteStackView()

        setupPostTitle()
        setupPostSummary()
        setupFeaturedImage()
        setupPostCounts()

        setupControlButtons()
        setupControlsStackView()

        setupSeparatorView()
    }

    func setupContentView() {
        contentView.backgroundColor = .listForeground
    }

    func setupContentStackView() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .leading
        contentStackView.spacing = Constants.ContentStackView.spacing
        contentView.addSubview(contentStackView)
    }

    func setupIconImage(_ imageView: UIImageView, containerView: UIView, image: UIImage?) {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = Constants.iconImageSize / 2.0
        imageView.layer.masksToBounds = true
        imageView.image = image
        containerView.addSubview(imageView)
        siteStackView.addArrangedSubview(containerView)
    }

    func setupSiteTitle() {
        siteTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        siteTitleLabel.font = .preferredFont(forTextStyle: .subheadline).semibold()
        siteTitleLabel.numberOfLines = 1
        siteTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        siteStackView.addArrangedSubview(siteTitleLabel)
    }

    func setupPostDate() {
        postDateLabel.translatesAutoresizingMaskIntoConstraints = false
        postDateLabel.font = .preferredFont(forTextStyle: .footnote)
        postDateLabel.numberOfLines = 1
        postDateLabel.textColor = .secondaryLabel
        siteStackView.addArrangedSubview(postDateLabel)
    }

    func setupSiteStackView() {
        siteStackView.translatesAutoresizingMaskIntoConstraints = false
        siteStackView.setCustomSpacing(Constants.SiteStackView.avatarSpacing, after: avatarContainerView)
        siteStackView.setCustomSpacing(Constants.SiteStackView.iconSpacing, after: siteIconContainerView)
        siteStackView.setCustomSpacing(Constants.SiteStackView.siteTitleSpacing, after: siteTitleLabel)
        contentStackView.addArrangedSubview(siteStackView)
    }

    func setupPostTitle() {
        postTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        postTitleLabel.font = .preferredFont(forTextStyle: .title3).semibold()
        postTitleLabel.numberOfLines = 2
        contentStackView.addArrangedSubview(postTitleLabel)
    }

    func setupPostSummary() {
        postSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        postSummaryLabel.font = .preferredFont(forTextStyle: .footnote)
        postSummaryLabel.numberOfLines = 3
        contentStackView.addArrangedSubview(postSummaryLabel)
    }

    func setupFeaturedImage() {
        featuredImageView.translatesAutoresizingMaskIntoConstraints = false
        featuredImageView.layer.cornerRadius = Constants.FeaturedImage.cornerRadius
        featuredImageView.layer.masksToBounds = true
        featuredImageView.contentMode = .scaleAspectFill
        contentStackView.addArrangedSubview(featuredImageView)
    }

    func setupPostCounts() {
        postCountsLabel.font = .preferredFont(forTextStyle: .footnote)
        postCountsLabel.numberOfLines = 1
        postCountsLabel.textColor = .secondaryLabel
        contentStackView.addArrangedSubview(postCountsLabel)
    }

    func setupControlButton(_ button: UIButton, image: UIImage?, text: String? = nil) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .secondaryLabel
        button.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.setImage(image, for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.setTitle(text, for: .normal)
        controlsStackView.addArrangedSubview(button)
    }

    func setupControlButtons() {
        setupControlButton(reblogButton, image: Constants.reblogButtonImage, text: Constants.reblogButtonText)
        setupControlButton(commentButton, image: Constants.commentButtonImage, text: Constants.commentButtonText)
        setupControlButton(likeButton, image: Constants.likeButtonImage, text: Constants.likeButtonText)
        setupFillerView()
        controlsStackView.addArrangedSubview(fillerView)
        setupControlButton(menuButton, image: Constants.menuButtonImage)
    }

    func setupFillerView() {
        fillerView.translatesAutoresizingMaskIntoConstraints = false
        fillerView.setContentHuggingPriority(Constants.fillerViewHuggingPriority, for: .horizontal)
        fillerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    func setupControlsStackView() {
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        controlsStackView.setCustomSpacing(Constants.ControlsStackView.reblogSpacing, after: reblogButton)
        controlsStackView.setCustomSpacing(Constants.ControlsStackView.commentSpacing, after: commentButton)
        controlsStackView.setCustomSpacing(Constants.ControlsStackView.likeSpacing, after: likeButton)
        contentView.addSubview(controlsStackView)
    }

    func setupSeparatorView() {
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .separator
        contentView.addSubview(separatorView)
    }

    // MARK: - View constraints

    func addViewConstraints() {
        NSLayoutConstraint.activate(
            contentViewConstraints()
            + iconImageConstraints(avatarImageView, containerView: avatarContainerView)
            + iconImageConstraints(siteIconImageView, containerView: siteIconContainerView)
            + featuredImageContraints()
            + buttonStackViewConstraints()
            + buttonConstraints()
            + separatorViewConstraints()
        )
    }

    func contentViewConstraints() -> [NSLayoutConstraint] {
        let margins = Constants.ContentStackView.margins
        return [
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margins),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margins),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margins),
            contentStackView.bottomAnchor.constraint(equalTo: controlsStackView.topAnchor,
                                                     constant: Constants.ContentStackView.bottomAnchor)
        ]
    }

    func iconImageConstraints(_ imageView: UIImageView, containerView: UIView) -> [NSLayoutConstraint] {
        return [
            containerView.heightAnchor.constraint(greaterThanOrEqualTo: imageView.heightAnchor),
            containerView.widthAnchor.constraint(greaterThanOrEqualTo: imageView.widthAnchor),
            imageView.heightAnchor.constraint(equalToConstant: Constants.iconImageSize),
            imageView.widthAnchor.constraint(equalToConstant: Constants.iconImageSize),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ]
    }

    func featuredImageContraints() -> [NSLayoutConstraint] {
        let heightAspectRatio = featuredImageView.heightAnchor.constraint(equalTo: featuredImageView.widthAnchor,
                                                                          multiplier: Constants.FeaturedImage.heightAspectMultiplier)
        heightAspectRatio.priority = .defaultHigh
        return [
            featuredImageView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            heightAspectRatio
        ]
    }

    func buttonStackViewConstraints() -> [NSLayoutConstraint] {
        return [
            controlsStackView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            controlsStackView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor,
                                                        constant: Constants.ControlsStackView.trailingConstraint),
            controlsStackView.bottomAnchor.constraint(equalTo: separatorView.topAnchor,
                                                      constant: Constants.ControlsStackView.bottomConstraint),
            controlsStackView.heightAnchor.constraint(equalToConstant: Constants.buttonMinimumSize)
        ]
    }

    func buttonConstraints() -> [NSLayoutConstraint] {
        let minimumSize = Constants.buttonMinimumSize
        return [
            reblogButton.widthAnchor.constraint(greaterThanOrEqualToConstant: minimumSize),
            commentButton.widthAnchor.constraint(greaterThanOrEqualToConstant: minimumSize),
            likeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: minimumSize),
            menuButton.widthAnchor.constraint(greaterThanOrEqualToConstant: minimumSize),
        ]
    }

    func separatorViewConstraints() -> [NSLayoutConstraint] {
        return [
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorHeight)
        ]
    }

    // MARK: - View configuration

    func configureLabels() {
        configureLabel(siteTitleLabel, text: viewModel?.siteTitle)
        configureLabel(postDateLabel, text: viewModel?.postDate)
        configureLabel(postTitleLabel, text: viewModel?.postTitle)
        configureLabel(postSummaryLabel, text: viewModel?.postSummary)
        configureLabel(postCountsLabel, text: viewModel?.postCounts)
    }

    func configureLabel(_ label: UILabel, text: String?) {
        guard let text else {
            label.removeFromSuperview()
            return
        }
        label.setText(text)
    }

    func configureImages() {
        configureAvatar()
        configureSiteIcon()
        configureFeaturedImage()
    }

    func configureAvatar() {
        guard let viewModel, viewModel.isAvatarEnabled else {
            removeFromStackView(siteStackView, view: avatarContainerView)
            return
        }
        viewModel.downloadAvatarIcon(for: avatarImageView)
    }

    func configureSiteIcon() {
        guard let viewModel, viewModel.isSiteIconEnabled else {
            removeFromStackView(siteStackView, view: siteIconContainerView)
            return
        }
        viewModel.downloadSiteIcon(for: siteIconImageView)
    }

    func configureFeaturedImage() {
        guard let viewModel, viewModel.isFeaturedImageEnabled else {
            removeFromStackView(siteStackView, view: featuredImageView)
            return
        }
        let imageViewSize = CGSize(width: featuredImageView.frame.width,
                                   height: featuredImageView.frame.height)
        viewModel.downloadFeaturedImage(with: imageLoader, size: imageViewSize)
    }

    func configureButtons() {
        guard let viewModel else {
            return
        }

        if !viewModel.isReblogEnabled {
            removeFromStackView(controlsStackView, view: reblogButton)
        }
        if viewModel.isCommentsEnabled {
            configureLikeButton()
        } else {
            removeFromStackView(controlsStackView, view: commentButton)
        }
        if !viewModel.isLikesEnabled {
            removeFromStackView(controlsStackView, view: likeButton)
        }
    }

    func configureLikeButton() {
        guard let isLiked = viewModel?.isPostLiked else {
            return
        }
        likeButton.setTitle(isLiked ? Constants.likedButtonText : Constants.likeButtonText, for: .normal)
        likeButton.setImage(isLiked ? Constants.likedButtonImage : Constants.likeButtonImage, for: .normal)
    }

    // MARK: - Cell reuse

    func addMissingViews() {
        let siteHeaderViews = [avatarContainerView, siteIconContainerView, siteTitleLabel, postDateLabel]
        let contentViews = [siteStackView, postTitleLabel, postSummaryLabel, featuredImageView, postCountsLabel]
        let controlViews = [reblogButton, commentButton, likeButton]

        siteHeaderViews.enumerated().forEach { (index, view) in
            addToStackView(siteStackView, view: view, index: index)
        }
        contentViews.enumerated().forEach { (index, view) in
            addToStackView(contentStackView, view: view, index: index)
        }
        controlViews.enumerated().forEach { (index, view) in
            addToStackView(controlsStackView, view: view, index: index)
        }

        siteStackView.setCustomSpacing(Constants.SiteStackView.avatarSpacing, after: avatarContainerView)
        siteStackView.setCustomSpacing(Constants.SiteStackView.iconSpacing, after: siteIconContainerView)
        siteStackView.setCustomSpacing(Constants.SiteStackView.siteTitleSpacing, after: siteTitleLabel)
        controlsStackView.setCustomSpacing(Constants.ControlsStackView.reblogSpacing, after: reblogButton)
        controlsStackView.setCustomSpacing(Constants.ControlsStackView.commentSpacing, after: commentButton)
        controlsStackView.setCustomSpacing(Constants.ControlsStackView.likeSpacing, after: likeButton)
    }

    func addToStackView(_ stackView: UIStackView, view: UIView, index: Int) {
        guard view.superview == nil, stackView.arrangedSubviews.count >= index else {
            return
        }
        stackView.insertArrangedSubview(view, at: index)
    }

    func removeFromStackView(_ stackView: UIStackView, view: UIView) {
        stackView.removeArrangedSubview(view)
        view.removeFromSuperview()
    }

    func resetElements() {
        avatarImageView.image = Constants.avatarPlaceholder
        siteIconImageView.image = Constants.siteIconPlaceholder
        siteTitleLabel.text = nil
        postDateLabel.text = nil
        postTitleLabel.text = nil
        postSummaryLabel.text = nil
        featuredImageView.image = nil
        postCountsLabel.text = nil
    }

}
