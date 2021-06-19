//
//  ContentView.swift
//  Devote
//
//  Created by Erik Salas on 6/17/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    //MARK: - PROPERTY
    @State var task: String = ""
    private var isButtonDisabled: Bool {
        task.isEmpty
    }
    
    //MARK: - FETCHING DATA
    /*
     Managed Object Context: An environment where we can manipulate Core Data objects entirely in RAM
     Add an @Environment object to read the managed object context right out
     the viewContext is a "scrachpad" to retrieve, update and store objects.
     
     */
    @Environment(\.managedObjectContext) private var viewContext
    
    /*
     FetchRequest allow us to load core data results that match the specific critera we specify
     swiftUI combines thse results directly to user interface elements
     
     it could potentily have four parametsrs
     entity: is what we want to query
     sort descriptor: determines in which order results are returned
     predicate: used to filter the data
     animation: used for any changes to the fetched results
     
     xcode's default core data template uses only the sort descriptor and animation
     */
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    //holds all items in the fetch result
    private var items: FetchedResults<Item>
    
    //MARK: - BODY
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 16) {
                    TextField("New Task", text: $task)
                        .padding()
                        .background(
                            Color(UIColor.systemGray6)
                        )
                        .cornerRadius(10)
                    
                    Button(action: {
                        addItem()
                    }, label: {
                        Spacer()
                        Text("SAVE")
                        Spacer()
                    })
                    .disabled(isButtonDisabled)
                    .padding()
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(isButtonDisabled ? Color.gray : Color.pink)
                    .cornerRadius(10)
                } //: VStack
                .padding()
                
                List {
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            Text(item.task ?? "")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        } //: List Item
                    }
                    .onDelete(perform: deleteItems)
                } //: List
            } //: VStack
            .navigationBarTitle("Daily Tasks", displayMode: .large)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                #endif
            } //: Toolbar
        } //: Navigation
    }
    
    //MARK: - FUNCTION
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.task = task
            newItem.completion = false
            newItem.id = UUID()
            
            do {
                try viewContext.save()
            } catch {
                
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            task = ""
            hideKeyboard()
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

//MARK: - PREVIEW

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
