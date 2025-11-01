import { Request, Response, NextFunction } from "express";
import * as admin from "firebase-admin";

/**
 * Middleware to verify user authentication
 * Expects userId in request body or query params
 */
export const verifyUser = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.body.userId || req.query.userId;

    if (!userId) {
      res.status(400).json({
        status: false,
        message: "User ID is required",
      });
      return;
    }

    // Verify user exists in Firestore
    const userDoc = await admin.firestore().collection("users").doc(userId).get();

    if (!userDoc.exists) {
      res.status(404).json({
        status: false,
        message: "User not found or session expired",
        error_code: "INVALID_USER_ID",
      });
      return;
    }

    // Attach user data to request
    (req as any).user = userDoc.data();
    (req as any).userId = userId;

    next();
  } catch (error: any) {
    console.error("User verification error:", error);
    res.status(500).json({
      status: false,
      message: "Error verifying user",
      error: error.message,
    });
  }
};

/**
 * Handle async route errors
 */
export const asyncHandler = (
  fn: (req: Request, res: Response, next: NextFunction) => Promise<void>
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

/**
 * Error handler middleware
 */
export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  console.error("Error:", err);
  res.status(500).json({
    status: false,
    message: err.message || "Internal server error",
  });
};

