# Expenses
<p>
“Expenses” is an application that helps users to track theirs expenses: invoices and receipts. Users are able to take photos of the expenses and add some info about them. Application works only with local data and maintains its state after closing.

Technologies used: SwiftUI and SwiftData
Tools: Xcode 15.4

Code is structured in two layers: Data and Views. 

Data layer handles creation, update and deletion using SwiftData concurrency model (@ModelActor) in thread safe manner. It complies with Swift’s strict concurrency standards. Data operations are unit tested.

ExpensesStore acts as a view model. Data is loaded incrementally, using a custom FetchDescriptor.

</p>

<div>
<img src="/readmeimg/add.PNG" alt="drawing" width="300"/>
<img src="/readmeimg/list.PNG" alt="drawing" width="300"/>
<img src="/readmeimg/edit.PNG" alt="drawing" width="300"/>
</div>
