//
//  ViewController.swift
//  Project5
//
//  Created by Kevin Chan on 8/30/20.
//  Copyright © 2020 Visionary. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    var word: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action:
            #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        if word == "" {
            startGame()
        } else {
            title = word
        }
        
    }
    
   @objc func startGame() {
        title  = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
//        let errorTitle: String
//        let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    if isTooShort(word: lowerAnswer) {
                        usedWords.insert(answer, at: 0)
                        
    //                    Top of table view
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        
                        return
                    }
                    else {
                        showErrorMessage(errTitle: "Word too short", errMessage: "Please enter the word more than 3 char.")
                    }
                } else {

                    showErrorMessage(errTitle: "Word not reconized", errMessage: "You can't just make them up, you know?")
                }
            } else {
               
                showErrorMessage(errTitle: "Word already used", errMessage: "Be more original!")
            }
        } else {
            guard let title = title else { return }

            showErrorMessage(errTitle: "Word not possible", errMessage: "You can't spell that word from \(title.lowercased()).")
        }
        
//        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .default))
//        present(ac, animated: true)
    }
    
    func showErrorMessage(errTitle: String, errMessage: String) {
        let ac = UIAlertController(title: errTitle, message: errMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isTooShort(word: String) -> Bool {
        return word.utf16.count >= 3
    }
    
    func isOriginal (word: String) -> Bool {
        return !usedWords.contains(word.lowercased())
    }
    
    func isReal (word: String) -> Bool {
        
        if self.word == word {
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range,
                                        startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }


}

