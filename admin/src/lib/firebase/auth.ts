import { 
  signInWithEmailAndPassword, 
  signOut, 
  onAuthStateChanged,
  User 
} from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from './config';

export const loginAdmin = async (email: string, password: string) => {
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;

    // Verify admin role
    const userDoc = await getDoc(doc(db, 'users', user.uid));
    if (!userDoc.exists() || userDoc.data()?.role !== 'admin') {
      await signOut(auth);
      throw new Error('User is not an admin');
    }

    return user;
  } catch (error: any) {
    throw new Error(error.message || 'Login failed');
  }
};

export const logoutAdmin = async () => {
  await signOut(auth);
};

export const checkAdminRole = async (user: User): Promise<boolean> => {
  try {
    const userDoc = await getDoc(doc(db, 'users', user.uid));
    return userDoc.exists() && userDoc.data()?.role === 'admin';
  } catch (error) {
    return false;
  }
};

export const onAdminAuthChange = (callback: (user: User | null) => void) => {
  return onAuthStateChanged(auth, callback);
};
