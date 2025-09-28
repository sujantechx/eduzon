
/// login are proper weorkin

/*
rules_version = '2';
service cloud.firestore {
match /databases/{database}/documents {
// Allow authenticated users to read their own user document
match /users/{uid} {
allow read: if request.auth != null && request.auth.uid == uid;
// Allow approved users to update their own document
allow write: if request.auth != null && request.auth.uid == uid
&& get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status in ['approved', 'approve'];
// Allow admins full read/write access
allow read, write: if request.auth != null
&& get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';

// Allow authenticated users to read/write their own device data
match /devices/{deviceId} {
allow read: if request.auth != null && request.auth.uid == uid;
allow write: if request.auth != null && request.auth.uid == uid
&& get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status in ['approved', 'approve'];
// Allow admins full read/write access
allow read, write: if request.auth != null
&& get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
}

// Allow approved users to read subjects, admins to read/write
match /subjects/{subjectId} {
allow read: if request.auth != null
&& get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status in ['approved', 'approve'];
allow write: if request.auth != null
&& get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';

// Allow approved users to read chapters, admins to read/write
match /chapters/{chapterId} {
allow read: if request.auth != null
&& get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status in ['approved', 'approve'];
allow write: if request.auth != null
&& get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
}
}
}

*/
/// registaion and login are fully work
/*

rules_version = '2';
service cloud.firestore {
match /databases/{database}/documents {
// Helper function to check if user is approved
function isApprovedUser() {
  return request.auth != null &&
      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'approved';
  }

// Helper function to check if user is admin
function isAdmin() {
  return request.auth != null &&
      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
  }

// Allow authenticated users to create/read their own user document
match /users/{uid} {
// Allow read if authenticated and matching UID
allow read: if request.auth != null && request.auth.uid == uid;
// Allow create for new users (authenticated, no existing document)
allow create: if request.auth != null && request.auth.uid == uid &&
request.resource.data.keys().hasAll(['role', 'status']) &&
request.resource.data.role == 'student' &&
request.resource.data.status == 'pending';
// Allow updates for approved users
allow update: if request.auth != null && request.auth.uid == uid && isApprovedUser() &&
request.resource.data.keys().hasAll(['role', 'status']);
// Allow admins full read/write access
allow read, write: if isAdmin();

match /devices/{deviceId} {
allow read: if request.auth != null && request.auth.uid == uid;
allow write: if request.auth != null && request.auth.uid == uid && isApprovedUser();
allow read, write: if isAdmin();
}
}

// Subjects and nested collections
match /subjects/{subjectId} {
allow read: if isApprovedUser();
allow write: if isAdmin();

match /chapters/{chapterId} {
allow read: if isApprovedUser();
allow write: if isAdmin();

match /videos/{videoId} {
allow read: if isApprovedUser();
allow write: if isAdmin();
}

match /pdfs/{pdfId} {
allow read: if isApprovedUser();
allow write: if isAdmin() &&
request.resource.data.keys().hasAll(['url', 'name']) &&
request.resource.data.url is string &&
request.resource.data.name is string;
}
}
}

// Optional: Logs for auditing
match /logs/{logId} {
allow read, write: if isAdmin();
}
}
}*/
/// video proper ply data are fatch
/*rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // --- HELPER FUNCTIONS (These are correct) ---
    function isApprovedUser() {
      return request.auth != null &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'approved';
    }

    function isAdmin() {
      return request.auth != null &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // --- USER RULES (These are correct) ---
    match /users/{uid} {
      allow read: if request.auth != null && request.auth.uid == uid;
      allow create: if request.auth != null; // Simplified for clarity
      allow update: if (request.auth != null && request.auth.uid == uid) || isAdmin();
      allow delete: if isAdmin();
    }

    // ✅ --- CORRECTED RULES FOR YOUR CONTENT ---
    // Start with your top-level 'courses' collection
    match /courses/{courseId} {
      // Grant access to the course document itself
      allow read: if isApprovedUser();
      allow write: if isAdmin();

      // Nest the rules for the 'subjects' sub-collection
      match /subjects/{subjectId} {
        allow read: if isApprovedUser();
        allow write: if isAdmin();

        // Nest the rules for the 'chapters' sub-collection
        match /chapters/{chapterId} {
          allow read: if isApprovedUser();
          allow write: if isAdmin();

          // Finally, nest the rules for the 'videos' sub-collection
          match /videos/{videoId} {
            allow read: if isApprovedUser();
            allow write: if isAdmin();
          }
          // (You can add your pdfs rules here too)
          match /pdfs/{pdfId} {
            allow read: if isApprovedUser();
            allow write: if isAdmin();
          }
        }
      }
    }
  }
}*/
/// login register and video are proper play and data fatch device id are store properwork
/*
rules_version = '2';
service cloud.firestore {
match /databases/{database}/documents {

// --- HELPER FUNCTIONS (These are correct) ---
function isApprovedUser() {
  return request.auth != null &&
      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'approved';
  }

function isAdmin() {
  return request.auth != null &&
      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
  }

// --- USER RULES (These are correct) ---
match /users/{uid} {
// Allow read if authenticated and matching UID
allow read: if request.auth != null && request.auth.uid == uid;
// Allow create for new users (authenticated, no existing document)
allow create: if request.auth != null && request.auth.uid == uid &&
request.resource.data.keys().hasAll(['role', 'status']) &&
request.resource.data.role == 'student' &&
request.resource.data.status == 'pending';
// Allow updates for approved users
allow update: if request.auth != null && request.auth.uid == uid && isApprovedUser() &&
request.resource.data.keys().hasAll(['role', 'status']);
// Allow admins full read/write access
allow read, write: if isAdmin();
match /devices/{deviceId} {
allow read: if request.auth != null && request.auth.uid == uid;
allow write: if request.auth != null && request.auth.uid == uid && isApprovedUser();
allow read, write: if isAdmin();
}
}

// ✅ --- CORRECTED RULES FOR YOUR CONTENT ---
// Start with your top-level 'courses' collection
match /courses/{courseId} {
// Grant access to the course document itself
allow read: if isApprovedUser();
allow write: if isAdmin();

// Nest the rules for the 'subjects' sub-collection
match /subjects/{subjectId} {
allow read: if isApprovedUser();
allow write: if isAdmin();

// Nest the rules for the 'chapters' sub-collection
match /chapters/{chapterId} {
allow read: if isApprovedUser();
allow write: if isAdmin();

// Finally, nest the rules for the 'videos' sub-collection
match /videos/{videoId} {
allow read: if isApprovedUser();
allow write: if isAdmin();
}
// (You can add your pdfs rules here too)
match /pdfs/{pdfId} {
allow read: if isApprovedUser();
allow write: if isAdmin();
}
}
}
}
}
}*/
