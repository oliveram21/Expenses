# Expenses
<p>
“Expenses” is an application that helps users to track theirs expenses: invoices and receipts. Users are able to take photos of the expenses and add some info about them. Application works only with local data.

Technologies used: SwiftUI and SwiftData
Tools: Xcode 15.4

Code is structured in two layers: Data and Views. 

Data layer handles creation, update and deletion using SwiftData concurrency model (@ModelActor) in thread safe manner. It complies with Swift’s strict concurrency standards. Data operations are unit tested.

View layer handles data display and reacts to changes of model, using @Query.  It is very well integrated with SwiftData, but the main limitation encountered is the lack of pagination support in order to limit number of data loaded since the beginning. This can be done adding some filtering.
Using a custom FetchDescriptor to load data incrementally complicated too much the logic of display when data was inserted, deleted or updated on background context.
</p>

<div>
<img src="/readmeimg/add.PNG" alt="drawing" width="300"/>
<img src="/readmeimg/list.PNG" alt="drawing" width="300"/>
<img src="/readmeimg/edit.PNG" alt="drawing" width="300"/>
</div>
