const admin = require('firebase-admin');

// Initialize without service account key (uses application default credentials)
admin.initializeApp({
  projectId: 'wamo-26a85'
});

async function createAdminUser() {
  try {
    // Create user
    const userRecord = await admin.auth().createUser({
      email: 'admin@wamo.com',
      password: 'Admin123!',
      displayName: 'Admin User'
    });

    console.log('✅ Admin user created in Authentication:', userRecord.uid);

    // Add admin role to Firestore
    await admin.firestore().collection('users').doc(userRecord.uid).set({
      email: 'admin@wamo.com',
      role: 'admin',
      displayName: 'Admin User',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log('✅ Admin role added to Firestore');
    console.log('\nLogin credentials:');
    console.log('Email: admin@wamo.com');
    console.log('Password: Admin123!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating admin user:', error.message);
    process.exit(1);
  }
}

createAdminUser();
