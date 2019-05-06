//
//  DeadlinesTableViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 5/2/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class DeadlinesTableViewController: UITableViewController {

    var deadlines = [String]()
    var dates = [String]()
    
    var currSemester = ""
    var currClass = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()

        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let deadlinesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("deadlines")

        deadlinesRef!.getDocument { (document, error) in
            if error != nil {
                print("Could not find document")
            }
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of semesters
                    DispatchQueue.main.async {
                        self.deadlines = data["deadlines"]! as! [String]
                        self.dates = data["dates"]! as! [String]
                        self.tableView.reloadData()
                    }
                })
            })
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        navigationItem.rightBarButtonItems?.append(add)
    }
    
    @objc func addTapped() {
        performSegue(withIdentifier: "deadlinesToAdd", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return deadlines.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deadlineCell", for: indexPath)

        // Configure the cell...

        let deadline = deadlines[indexPath.row]
        cell.textLabel?.text = deadline
        print("dates array = ", dates, deadlines)
        let date = dates[indexPath.row]
        
        cell.detailTextLabel?.text = date
        
        cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor(red:0.54, green:1.00, blue:0.71, alpha:1.0)
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let db = Firestore.firestore()
            
            var userRef: DocumentReference? = nil
            userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
            
            let deadlinesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes").collection(currClass).document("deadlines")
            
            deadlinesRef?.updateData([
                "deadlines": FieldValue.arrayRemove([deadlines[indexPath.row]]), "dates": FieldValue.arrayRemove([dates[indexPath.row]])
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            
            
            deadlines.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addDeadlinesVC = segue.destination as? AddDeadlineViewController {
            addDeadlinesVC.callback1 = { message in
                let db = Firestore.firestore()
                var userRef: DocumentReference? = nil
                userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
                let deadlinesRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("deadlines")
                deadlinesRef?.updateData([
                    "deadlines": FieldValue.arrayUnion([message])
                ])
                self.deadlines.append(message)
                print(self.deadlines)
            }
            addDeadlinesVC.callback2 = { message in
                let db = Firestore.firestore()
                var userRef: DocumentReference? = nil
                userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
                let datesRef = userRef?.collection("semesters").document("semesters").collection(self.currSemester).document("classes").collection(self.currClass).document("deadlines")
                datesRef?.updateData([
                    "dates": FieldValue.arrayUnion([message])
                ])
                self.dates.append(message)
                print(self.dates)
            }
        }
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

}
