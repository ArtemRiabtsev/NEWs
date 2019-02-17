//
//  AsincOperation.swift
//  NEWs
//
//  Created by Артем Рябцев on 2/10/19.
//  Copyright © 2019 Артем Рябцев. All rights reserved.
//

import UIKit
class AsyncOperation: Operation {
    public enum State: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
    
    public var state: State = .ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        
        main()
        state = .executing
    }
    
    override func cancel() {
        super.cancel()
        state = .finished
    }
}

class DownloadOperation: AsyncOperation {
    let path: String
    var resultError: String?
    var image: UIImage?
    init(path: String) {
        self.path = path
    }
    
    override func main() {
        
        getImage(self.path) { (image, error) in
            self.image = image
            self.resultError = error
            self.state = .finished
        }
    }
}

fileprivate func getImage(_ path: String, complition: @escaping (UIImage?, String?) -> Void) {
    guard let url = URL(string: path) else { return }
    URLSession.shared.dataTask(with: url) { (data, nil, error) in
        if let err = error {
            print(err.localizedDescription)
            let message = "Download failed"
            complition(nil, message)
        }
        if let data = data  {
            let image = UIImage(data: data)
            complition(image, nil)
        }
    }.resume()
}

