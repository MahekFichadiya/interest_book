import { Router, Request, Response } from "express";
import * as admin from "firebase-admin";
import { asyncHandler } from "../utils/middleware";
import db from "../utils/firestore";

const router = Router();

/**
 * POST /auth/login
 * Login user with email and password
 */
router.post(
  "/login",
  asyncHandler(async (req: Request, res: Response) => {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).json({
        status: false,
        message: "Email and password are required",
      });
      return;
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      res.status(400).json({
        status: false,
        message: "Please enter a valid email address",
      });
      return;
    }

    // Find user by email
    const usersRef = db.collection("users");
    const snapshot = await usersRef.where("email", "==", email.trim()).get();

    if (snapshot.empty) {
      res.status(404).json({
        status: false,
        message: "User not found",
      });
      return;
    }

    const userDoc = snapshot.docs[0];
    const userData = userDoc.data();

    // Verify password using bcrypt (stored in Firestore)
    const bcrypt = require("bcryptjs");
    const isPasswordValid = await bcrypt.compare(password, userData.password);

    if (!isPasswordValid) {
      res.status(401).json({
        status: false,
        message: "Invalid password",
      });
      return;
    }

    // Remove password from response
    delete userData.password;

    res.json({
      status: true,
      message: "Login successful",
      data: {
        userId: userDoc.id,
        ...userData,
      },
    });
  })
);

/**
 * POST /auth/signup
 * Register new user
 */
router.post(
  "/signup",
  asyncHandler(async (req: Request, res: Response) => {
    const { name, mobileNo, email, password } = req.body;

    if (!name || !mobileNo || !email || !password) {
      res.status(400).json({
        status: false,
        message: "Missing required fields",
      });
      return;
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      res.status(400).json({
        status: false,
        message: "Invalid email format",
      });
      return;
    }

    // Validate mobile number (basic validation)
    const mobileRegex = /^[\d\s\+\-\(\)]+$/;
    if (!mobileRegex.test(mobileNo)) {
      res.status(400).json({
        status: false,
        message: "Invalid mobile number format",
      });
      return;
    }

    // Check if email already exists
    const usersRef = db.collection("users");
    const emailSnapshot = await usersRef.where("email", "==", email.trim()).get();

    if (!emailSnapshot.empty) {
      res.status(409).json({
        status: false,
        message: "User with this email already exists",
      });
      return;
    }

    // Check if mobile number already exists
    const mobileSnapshot = await usersRef
      .where("mobileNo", "==", mobileNo.trim())
      .get();

    if (!mobileSnapshot.empty) {
      res.status(409).json({
        status: false,
        message: "User with this phone number already exists",
      });
      return;
    }

    // Hash password
    const bcrypt = require("bcryptjs");
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user document
    const userData = {
      name: name.trim(),
      mobileNo: mobileNo.trim(),
      email: email.trim(),
      password: hashedPassword,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
    };

    const userRef = await usersRef.add(userData);
    const userId = userRef.id;

    res.status(201).json({
      status: true,
      message: "User registered successfully",
      userId: userId,
    });
  })
);

export default router;

