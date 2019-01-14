# Project README


## 1. Project Scope
Problem Statement: Physical copies of books are left unused once read, leading to wastage of resources.

Solution: A social-networking platform for book readers to share their hard copy books.

Platform: Android / iOS.

Target audience: Book readers who would like to share and/or exchange their hard copy books.

## Benefits:
Minimises wastage of books as they are shared within the community.
A faster and cheaper alternative to obtaining desired books, compared to searching for them in a library / purchasing one online or in a store.
Encourage networking with one another.

Level of Achievement: Apollo 11


## 2. Proposed Features
### Core features:
Create a personal profile that other users can view.
Include basic details such as name, contact info and book collection.
For other users to find out more about the user that they are sharing a book with.
‘My Library’ section for users to create, update and delete their old book listings.
When searching for a book, it will link to a list of users with that particular book in their library.
Able to browse through the library of book listings by other users in their profile.
Look through other books that the user might want to borrow, in addition to the book that the user searched for.
Search engine for other users’ profile (search by users’ name).
To easily find friends that the user knows.
To easily find and contact other users that the user have shared a book with.
Search engine for books (search by book title, topic, or author).
After selecting a book, there will be a link to other users’ profiles who have that particular book in their library.
To easily look for books that the user wants to read.
Chat function to communicate with other users.
To discuss how the user wants to share the book (through meetup / mail etc).
Also serves as a networking tool if users want to discuss about the book.
   5.  Verification of return.
Allow users to verify that they have received the book they have loaned out in good condition.
Allow users to open disputes, if necessary. 

### Good to have features:
‘My Wishlist’ to keep track of the books wanted by the user.
If the book that the user is looking for is not in anyone’s library, the user can add that book into his/her wishlist. The application will notify the user when a user adds that book to his/her library. 
Notifications.
Alert the user when a match is found between two users’ wishlist and library.
Alert the user when nearing the due date to return a book.
Transaction page.
Include date of transaction and due date of books to be returned.
To easily keep track of books that the user have lent / borrowed.
Add other users as friends.
Encourages networking. Also makes it easier to access a friend’s profile if the user feels that they share similar interests in books, and would like to connect with him/her further.
My Friend Page.
Ease of navigation to their friends, so they can keep up to date in the event they have any new books the user might be interested in borrowing. 
     6.  My Chats Page.
Allow the user to keep track of all his chats in a seamless manner.  
 

### System dependencies:
Android Studio
Google Books API
Google / Facebook / Twitter login authentication (Firebase)
Flutter (sqflite)

Database creation / Initialisation:
Firebase (Cloud Firestore (store information on books, users, requests & notifications), Realtime Database (chat functionality)).

### 3. What have we done? 
Google login & authentication.
Creating and editing profile. (Information stored in cloud firestore)
Integration with Firebase analytics - for updates on crashes etc. 
Search engine for books.
Search engine for users.
Chat functionality with users.
View the collection of other users. 
Add other users as friends. 
Transaction history page - view all pending borrow requests, view your loaned out items with a single tap. 
Create and update your user profile.
User profile page - 
My Library of books.
My Wishlist of books.
Setting a date for the return of books - when user loans out his/her book.
My chats page - for users to monitor the chat (layout can be seen in the poster). 

## 4. What next?
Perhaps implementing an in-app currency system to incentivise users to share their books. 
Continously gather feedback from friends to improve the app and add the features in demand. 
Expanding our user base. As of now, our database only has 6 users. More users means more books, and it’ll be better for our users. 

## 5. Some screenshots
In our video, some of the features were omitted to prevent obstruction of flow in the video. These screenshots will supplement our video.Video link: https://gallery.moovly.com/video/34b66f42-43f3-432e-b9f1-f70f8ed08759










## 6. Some bugs squashed and problems encountered
Flutter is a relatively new SDK from Google, so the number of resources available is relatively little. In cases we were stuck, there were likely no solutions / similar questions posted on stackoverflow / flutter’s git rep, so our problem solving was mostly via brute force trial and error - a grueling and tiring, yet meaningful experience. 

We faced bugs while implementing some of the features like the borrow requests page, because of mismatch of keys (since Firebase database stores the database mostly as a JSON object). Because each object has various fields (e.g Book -> ownerEmail, borrowerEmail, isAvailable etc.), a small error in parsing an object into a JSON caused lots of hours of debugging.

## 7. Edge features developed
Implementation of the chat app to allow users to chat with one another. 
Implementation of the search users functionality and the ability to add and follow your friends in the app. 

## 8. User testing
One limitation of our app is that it only has 5 current users. We are unable to test the scalability with such a small sample size. 

Testing was done thoroughly to emulate the entire workflow:
User A searches the book he wants.
User A finds that User B has this book that he wants.
User A is able to request to borrow the book from User B via the app, and is also able to chat with User B to arrange a date, time and place to meet and exchange books.
User B can then set a date whereby he / she would like the book back.
Once User A is done with the book, they can make arrangements to return the books. 
Users can also search one another directly via the app, and can add one another as friends - to stay in touch. 

Thankfully, it works ;)

We welcome your feedback so we can continue to improve the app! :)















