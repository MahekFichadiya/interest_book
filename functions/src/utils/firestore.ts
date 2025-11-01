import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Firestore collection names
 */
export const COLLECTIONS = {
  USERS: "users",
  CUSTOMERS: "customers",
  LOANS: "loans",
  DEPOSITS: "deposits",
  INTERESTS: "interests",
  LOAN_DOCUMENTS: "loan_documents",
  HISTORY_CUSTOMERS: "history_customers",
  HISTORY_LOANS: "history_loans",
  HISTORY_DOCUMENTS: "history_documents",
};

/**
 * Generate unique ID (using Firestore auto-ID style)
 */
export const generateId = () => {
  return db.collection("_temp").doc().id;
};

/**
 * Get timestamp
 */
export const getTimestamp = () => {
  return admin.firestore.Timestamp.now();
};

/**
 * Convert Firestore timestamp to date string
 */
export const timestampToDateString = (timestamp: admin.firestore.Timestamp): string => {
  return timestamp.toDate().toISOString();
};

/**
 * Convert date string to Firestore timestamp
 */
export const dateStringToTimestamp = (dateString: string): admin.firestore.Timestamp => {
  return admin.firestore.Timestamp.fromDate(new Date(dateString));
};

/**
 * Calculate monthly interest
 */
export const calculateMonthlyInterest = (amount: number, rate: number): number => {
  return Math.round((amount * rate) / 100 * 100) / 100;
};

/**
 * Calculate daily interest
 */
export const calculateDailyInterest = (monthlyInterest: number): number => {
  return Math.round((monthlyInterest / 30) * 100) / 100;
};

/**
 * Calculate total interest based on months passed
 */
export const calculateTotalInterest = (
  monthlyInterest: number,
  startDate: admin.firestore.Timestamp,
  endDate?: admin.firestore.Timestamp
): number => {
  const now = endDate || getTimestamp();
  const start = startDate.toDate();
  const end = now.toDate();

  const monthsPassed = Math.floor(
    (end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24 * 30)
  );

  if (monthsPassed < 1) {
    return 0;
  }

  return Math.round(monthlyInterest * monthsPassed * 100) / 100;
};

/**
 * Batch write helper
 */
export const batchWrite = async (
  operations: Array<{
    type: "create" | "update" | "delete";
    collection: string;
    id: string;
    data?: any;
  }>
): Promise<void> => {
  const batch = db.batch();

  for (const op of operations) {
    const ref = db.collection(op.collection).doc(op.id);

    switch (op.type) {
      case "create":
        batch.set(ref, op.data!);
        break;
      case "update":
        batch.update(ref, op.data!);
        break;
      case "delete":
        batch.delete(ref);
        break;
    }
  }

  await batch.commit();
};

export default db;

