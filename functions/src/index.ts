import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as express from "express";
import * as cors from "cors";

// Initialize Firebase Admin
admin.initializeApp();

// Import route handlers
import authRoutes from "./routes/auth";
import customerRoutes from "./routes/customer";
import loanRoutes from "./routes/loan";
import depositRoutes from "./routes/deposit";
import interestRoutes from "./routes/interest";
import profileRoutes from "./routes/profile";
import documentRoutes from "./routes/documents";

const app = express();

// Middleware
app.use(cors({ origin: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use("/auth", authRoutes);
app.use("/customer", customerRoutes);
app.use("/loan", loanRoutes);
app.use("/deposit", depositRoutes);
app.use("/interest", interestRoutes);
app.use("/profile", profileRoutes);
app.use("/documents", documentRoutes);

// Health check
app.get("/", (req, res) => {
  res.json({ status: true, message: "Interest Book API is running" });
});

// Export as Firebase Cloud Function
export const api = functions.https.onRequest(app);

