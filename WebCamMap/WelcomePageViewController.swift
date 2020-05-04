//
//  WelcomePageViewController.swift
//  WebCamMap
//
//  Created by Nemanja Petrovic on 01/05/2020.
//  Copyright © 2020 Nemanja Petrovic. All rights reserved.
//

import UIKit

class WelcomePageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // To prepend a new transition before an old one is not completed, I added a transitioning flag to avoid error message "Unbalanced calls to begin/end appearance transitions for".
    var isTransitioning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        if let firstVC = pages.first
        {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }

    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "FirstPageController"),
            self.getViewController(withIdentifier: "SecondPageController")
        ]
    }()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0, self.isTransitioning == false
            else {
                return nil
        }
        
        guard pages.count > previousIndex
            else {
                return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count, self.isTransitioning == false
            else {
                return nil
        }
        
        guard pages.count > nextIndex else
        {
            return nil
        }
        
        return pages[nextIndex]
    }
    
    // Next two methods needed for page control - 3 dots.
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        setupPageControl()
        return self.pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = .gray
        appearance.currentPageIndicatorTintColor = #colorLiteral(red: 1, green: 0.764875771, blue: 0.2167999077, alpha: 1)
        appearance.backgroundColor = .darkGray
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.isTransitioning = true
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.isTransitioning = false
    }
}
