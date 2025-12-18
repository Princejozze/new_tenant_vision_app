# Deploy Firebase Storage Rules

## Quick Steps:

1. **Open Firebase Console Storage Rules:**
   https://console.firebase.google.com/project/tenant-database-dd733/storage/rules

2. **Copy the rules below and paste into the editor:**

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    function isAuthenticated() {
      return request.auth != null;
    }
    
    match /landlords/{allPaths=**} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
    
    match /tenants/{allPaths=**} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
    
    match /houses/{allPaths=**} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
  }
}
```

3. **Click "Publish" button**

4. **Done!** Image uploads should now work.
