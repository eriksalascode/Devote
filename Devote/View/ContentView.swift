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
    //"isDarkMode" is a key in the SwiftUI's user defaults
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State var task: String = ""
    @State private var showNewTaskItem: Bool = false

    
    //MARK: - FETCHING DATA
    /*
     Managed Object Context: An environment where we can manipulate Core Data objects entirely in RAM
     Add an @Environment object to read the managed object context right out
     the viewContext is a "scratchpad" to retrieve, update and store objects.
     
     */
    @Environment(\.managedObjectContext) private var viewContext
    
    /*
     FetchRequest allow us to load core data results that match the specific criteria we specify
     swiftUI combines these results directly to user interface elements
     
     it could potentially have four parameters
     entity: is what we want to query
     sort descriptor: determines in which order results are returned
     predicate: used to filter the data
     animation: used for any changes to the fetched results
     
     Xcode's default core data template uses only the sort descriptor and animation
     */
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    //holds all items in the fetch result
    private var items: FetchedResults<Item>
    
    //MARK: - BODY
    var body: some View {
        NavigationView {
            ZStack {
                //MARK: - Main View
                VStack {
                    //MARK: - Header
                    HStack(spacing: 10) {
                        //Title
                        Text("Devote")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.heavy)
                            .padding(.leading, 4)
                        Spacer()
                        //Edit Button
                        EditButton()
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 10)
                            .frame(minWidth: 70, minHeight: 24)
                            .background(
                                Capsule().stroke(Color.white, lineWidth: 2)
                            )
                        //Appearance Button
                        Button(action: {
                            //Toggle Appearance
                            isDarkMode.toggle()
                        }, label: {
                            Image(systemName: isDarkMode ? "moon.circle.fill" : "moon.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .font(.system(.title, design: .rounded))
                        })
                    } //: HStack
                    .padding()
                    .foregroundColor(.white)
                    Spacer(minLength: 80)
                    //MARK: - New Task Button
                    Button(action: {
                        showNewTaskItem = true
                    }, label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                        Text("New Task")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                    })
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                            .clipShape(Capsule())
                    )
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 8, x: 0.0, y: 4.0)
                    //MARK: - Tasks
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
                    .listStyle(InsetGroupedListStyle())
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.3), radius: 12)
                    .padding(.vertical, 0)
                    .frame(maxWidth: 640) //maximize the list on iPads
                } //: VStack
                //MARK: - New Task Item
                if showNewTaskItem {
                    BlankView()
                        .onTapGesture {
                            withAnimation() {
                                showNewTaskItem = false
                            }
                        }
                    NewTaskItemView(isShowing: $showNewTaskItem)
                }
            } //: ZStack
            .onAppear() {
                UITableView.appearance().backgroundColor = UIColor.clear
            }
            .navigationBarTitle("Daily Tasks", displayMode: .large)
            .navigationBarHidden(true)
            .background(
                BackgroundImageView()
            )
            .background(
                backgroundGradient.ignoresSafeArea(.all)
            )
        } //: Navigation
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    //MARK: - FUNCTION
    

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
