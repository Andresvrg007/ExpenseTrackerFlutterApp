import { Router } from 'express';
import { registerUser } from '../controllers/registerController.js';
import { loginUser } from '../controllers/loginController.js';
import { verifyAuth, logout } from '../controllers/authController.js';
import { updatePassword } from '../controllers/updatePassword.js';
import { saveSalary, getProfile } from '../controllers/userController.js';
import { addTransaction, getTransactionsSummary, resetMonthlyTransactions, getTransactions, updateTransaction, deleteTransaction } from '../controllers/transactionController.js';

// Solo define el router y las rutas
const router = Router();

router.post('/register', registerUser);
router.post('/login', loginUser);
router.get('/verify', verifyAuth);
router.post('/logout', logout);
router.post('/password', updatePassword);
router.post('/salary', saveSalary);
router.get('/profile', getProfile);
router.post('/transaction', addTransaction);
router.get('/transactions', getTransactions);
router.put('/transaction/:id', updateTransaction);
router.delete('/transaction/:id', deleteTransaction);
router.get('/transactions-summary', getTransactionsSummary);
router.post('/reset-monthly', resetMonthlyTransactions);

export default router;

