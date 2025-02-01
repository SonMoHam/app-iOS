//
//  HomeViewController.swift
//  EveryTipPresentation
//
//  Created by 김경록 on 6/10/24.
//  Copyright © 2024 EveryTip. All rights reserved.
//

import UIKit

import EveryTipDesignSystem
import EveryTipDomain


import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

final class HomeViewController: BaseViewController {
    
    
    weak var coordinator: HomeViewCoordinator?
    
    var disposeBag = DisposeBag()
    
    init(reactor: HomeReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private let roundedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setRoundedCorners(
            radius: 15,
            corners: .layerMinXMinYCorner, .layerMaxXMinYCorner
        )
        
        return view
    }()
    
    private let weeklyTipLabel: UILabel = {
        let label = UILabel()
        label.text = "코끼리는 유일하게 OO를\n하지 못하는 포유류입니다 "
        label.textColor = .white
        label.font = UIFont.et_pretendard(
            style: .extraBold,
            size: 18
        )
        
        label.numberOfLines = 0
        
        return label
    }()
    
    private let weeklyTipLearnMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("자세히 보기 >", for: .normal)
        button.tintColor = .white
        
        return button
    }()
    
    private let weeklyTipImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.et_getImage(for: .homeViewEmoji)
        
        return imageView
    }()
    
    private let searchBarButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(hex: "#F6F6F6")
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    private let searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.et_getImage(for: .searchIcon)
        
        return imageView
    }()
    
    private let postListTableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .grouped
        )
        tableView.backgroundColor = .white
        return tableView
    }()
    
    // MARK: TableViewDataSource
    
    private let dataSource = RxTableViewSectionedReloadDataSource<HomeTableViewSection>(
        configureCell: { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PostListCell.reuseIdentifier,
                for: indexPath
            ) as? PostListCell else { return UITableViewCell() }
            
            cell.configureCategoryLabel(id: 1)
            cell.configureTitleLabelText(item.title)
            cell.userNameLabel.text = item.userName
            cell.viewsCountLabel.text = "\(item.viewCount)"
            cell.likesCountLabel.text = "\(item.likeCount)"
            cell.mainTextLabel.text = item.mainText
            
            return cell
        }
    )
    
    //MARK: ViewLifeCycle
    
    override func viewDidLoad() {
        view.backgroundColor = .et_brandColor2
        setupLayout()
        setupConstraints()
        setupTableView()
    }
    
    // MARK: Private Methods
    
    private func setupLayout() {
        view.addSubview(weeklyTipLabel)
        view.addSubview(weeklyTipImageView)
        view.addSubview(weeklyTipLearnMoreButton)
        view.addSubview(roundedBackgroundView)
        
        roundedBackgroundView.addSubview(searchBarButton)
        searchBarButton.addSubview(searchIcon)
        roundedBackgroundView.addSubview(postListTableView)
    }
    
    private func setupConstraints() {
        roundedBackgroundView.snp.makeConstraints {
            $0.top.equalTo(weeklyTipImageView.snp.bottom).offset(30)
            $0.leading.trailing.bottom.equalTo(view)
        }
        
        weeklyTipLabel.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
        }
        
        weeklyTipLearnMoreButton.snp.makeConstraints {
            $0.top.equalTo(weeklyTipLabel.snp.bottom).offset(5)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
        }
        
        weeklyTipImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-30)
            $0.width.equalTo(view.snp.width).multipliedBy(0.29)
            $0.height.equalTo(weeklyTipImageView.snp.width).multipliedBy(0.955)
        }
        
        searchBarButton.snp.makeConstraints {
            $0.top.equalTo(roundedBackgroundView.snp.top).offset(12)
            $0.leading.equalTo(roundedBackgroundView).offset(15)
            $0.trailing.equalTo(roundedBackgroundView).offset(-15)
            $0.height.equalTo(40)
        }
        
        searchIcon.snp.makeConstraints {
            $0.top.equalTo(searchBarButton).offset(11)
            $0.bottom.equalTo(searchBarButton).offset(-11)
            $0.trailing.equalTo(searchBarButton.snp.trailing).offset(-11)
        }
        
        postListTableView.snp.makeConstraints {
            $0.top.equalTo(searchBarButton.snp.bottom).offset(20)
            $0.leading.equalTo(roundedBackgroundView)
            $0.trailing.equalTo(roundedBackgroundView)
            $0.bottom.equalTo(roundedBackgroundView)
        }
    }
    
    private func setupTableView() {
        postListTableView.register(
            PostListCell.self,
            forCellReuseIdentifier: PostListCell.reuseIdentifier
        )
        postListTableView.register(
            HomeSectionHeaderView.self,
            forHeaderFooterViewReuseIdentifier: HomeSectionHeaderView.reuseIdentifier
        )
        postListTableView.indicatorStyle = .white
        postListTableView.separatorStyle = .none
        postListTableView.rowHeight = UITableView.automaticDimension
        postListTableView.estimatedRowHeight = 130
    }
}

//MARK: Reactor

extension HomeViewController: View {
    func bind(reactor: HomeReactor) {
        bindInputs(to: reactor)
        bindOutputs(to: reactor)
    }
    
    private func bindInputs(to reactor: HomeReactor) {
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        postListTableView.rx.itemSelected
            .map{Reactor.Action.itemSeleted($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        postListTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bindOutputs(to reactor: HomeReactor) {
        
        reactor.state
            .map { $0.fetchError }
            .subscribe(onNext: { error in
                if let error = error {
                    print("Error: \(error)")
                    // 에러 핸들링 로직 추가 (예: Alert 표시)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedItem }
            .compactMap{ $0 }
            .subscribe(onNext: { [weak self] tip in
                self?.coordinator?.navigateToTestView(with: tip)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.posts }
            .map { posts in
                // TODO: api 출시후 리액터 재정의 필요
                let empty: [Tip] = []
                return [
                    HomeTableViewSection(
                        sectionType: .popular,
                        items: posts
                    ),
                    HomeTableViewSection(
                        sectionType: .interestCategory,
                        items: empty
                    )
                ]
            }
            .bind(to: postListTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: TableView Delegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: HomeSectionHeaderView.reuseIdentifier
        ) as? HomeSectionHeaderView else { return UIView() }
        
        let headerTitle = dataSource.sectionModels[section].sectionType.hederTitle
        headerView.setTitleLabel(headerTitle)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch dataSource.sectionModels[section].sectionType {
        case .popular:
            return SeparatorStyleFooterView()
            
        case .interestCategory:
            let suggestView = InterestSuggestFooterView()
            suggestView.delegate = self
            
            return suggestView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch dataSource.sectionModels[section].sectionType {
        case .popular:
            return 50
            
        case .interestCategory:
            if coordinator?.checkIsLoggedin() == false
            /*|| 선택된 카테고리가 없다면.. */ {
                return 250
            } else {
                return 0
            }
        }
    }
}

// MARK: Button Delegate
extension HomeViewController: FooterDelegate {
    func buttonTapped() {
        coordinator?.checkLoginBeforeAction(onLoggedIn: {
            // TODO: 실제 코디네이터 동작 삽임 필요
            print("coordinator.moveToSetCategoryView")
        })
    }
}
