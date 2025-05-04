
//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 19/10/2024.
//

import UIKit
@preconcurrency import WebKit

/*enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}*/
public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    
        func load(request: URLRequest)
        func setProgressValue(_ newValue: Float)
        func setProgressHidden(_ isHidden: Bool)
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    weak var delegate: WebViewViewControllerDelegate?
    //private let webViewHelper: WebViewHelperProtocol
    var presenter: WebViewPresenterProtocol?
    
    
    // MARK: - IB Outlets
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: - KVO Observation
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Инициализация
    
    init(presenter: WebViewPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter?.view = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /*   init(webViewHelper: WebViewHelperProtocol = WebViewHelper()) {
           self.webViewHelper = webViewHelper
           super.init(nibName: nil, bundle: nil)
       }
    
    required init?(coder: NSCoder) {
            self.webViewHelper = WebViewHelper() // <-- По умолчанию используем обычный WebViewHelper
            super.init(coder: coder)
        }
     */
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WebViewViewController loaded")
        //loadAuthView()
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
        //updateProgress()
        
        // Настройка KVO для наблюдения за estimatedProgress
                estimatedProgressObservation = webView.observe(
                    \.estimatedProgress,
                    options: [],
                    changeHandler: { [weak self] _, _ in
                     // self?.updateProgress()
                    }
                )
            }
    
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           estimatedProgressObservation = nil // Отключение наблюдения
       }
    
    // MARK: - Private Methods
    
   /* private func loadAuthView() {
            guard let request = webViewHelper.makeAuthRequest() else {
                print("Ошибка: не удалось создать запрос авторизации.")
                return
            }
            webView.load(request)
        }*/
    
  /*  private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }*/
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    
    // MARK: - IB Actions
    @IBAction private func backButtonTapped(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
   /* private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }*/
}
