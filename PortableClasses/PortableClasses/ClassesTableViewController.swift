//
//  ClassesTableViewController.swift
//  PortableClasses
//
//  Created by Anthony Ramirez on 4/27/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class ClassesTableViewController: UITableViewController {
    
    var classes = [String]()
    var currSemester = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        classesTableView.rowHeight = 90
        
        let db = Firestore.firestore()

        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let classesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes")
        
        classesRef!.getDocument { (document, error) in
            if error != nil {
                print("Could not find document")
            }
            _ = document.flatMap({
                $0.data().flatMap({ (data) in
                    // asynchronously reload table once db returns array of semesters
                    DispatchQueue.main.async {
                        self.classes = data["classes"]! as! [String]
                        self.tableView.reloadData()
                    }
                })
            })
        }
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add Course", message: nil, preferredStyle: .alert)
        alert.addTextField {(courseTF) in
            courseTF.placeholder = "Enter Course Name"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let course = alert.textFields?.first?.text else {return}
            self.add(course)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (_) in
            return
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true)
    }
    
    func add(_ course: String) {
        
        let db = Firestore.firestore()
        
        var userRef: DocumentReference? = nil
        
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        let classesRef = userRef?.collection("semesters").document("semesters").collection(currSemester).document("classes")
        // add new course collection
        let newCourseCollection = classesRef?.collection(course)
        
        // append semester
        classesRef?.updateData([
            "classes": FieldValue.arrayUnion([course])
        ]) { err in
            if err != nil {
                print("Error adding course")
            } else {
                // initialize notes, handNotes, deadlines, & flashcards arrays for this course
                let currClassRef = classesRef?.collection(course)
                let notesDoc = currClassRef?.document("notes")
                let handNotesDoc = currClassRef?.document("handNotes")
                let deadlinesDoc = currClassRef?.document("deadlines")
                let flashcardsDoc = currClassRef?.document("flashcards")
                
                // initialize notes array
                notesDoc?.setData([
                    "notes": [],
                ]) { err in
                    if err != nil {
                        print("Error adding notes")
                    }
                }
                
                // initialize hand notes array
                handNotesDoc?.setData([
                    "handNotes": [],
                    ]) { err in
                        if err != nil {
                            print("Error adding hand notes")
                        }
                }
                
                // initialize dealines array
                deadlinesDoc?.setData([
                    "deadlines": [],
                    ]) { err in
                        if err != nil {
                            print("Error adding deadlines")
                        }
                }
                
                // initialize notes array
                flashcardsDoc?.setData([
                    "flashcards": [],
                    ]) { err in
                        if err != nil {
                            print("Error adding flash cards")
                        }
                }
                
                
                
                let index = 0
                self.classes.insert(course, at: index)
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .left)
            }
        }
    }
  
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return classes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath)
        
            cell.backgroundColor = UIColor(cgColor: (tableView.backgroundColor?.cgColor)!)
    
            let course = classes[indexPath.row]
            cell.textLabel?.text = course
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

