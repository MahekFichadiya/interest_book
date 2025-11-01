import { v2 as cloudinary } from "cloudinary";
import * as functions from "firebase-functions";

// Configure Cloudinary
// IMPORTANT: Set these in Firebase Functions config:
// firebase functions:config:set cloudinary.cloud_name="your_cloud_name"
// firebase functions:config:set cloudinary.api_key="your_api_key"
// firebase functions:config:set cloudinary.api_secret="your_api_secret"

const cloudinaryConfig = functions.config().cloudinary || {
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME || "",
  api_key: process.env.CLOUDINARY_API_KEY || "",
  api_secret: process.env.CLOUDINARY_API_SECRET || "",
};

cloudinary.config({
  cloud_name: cloudinaryConfig.cloud_name,
  api_key: cloudinaryConfig.api_key,
  api_secret: cloudinaryConfig.api_secret,
});

/**
 * Upload image to Cloudinary
 * @param filePath - Path to the file or base64 string
 * @param folder - Folder name in Cloudinary (e.g., 'customer_images', 'loan_documents')
 * @param publicId - Optional public ID for the image
 * @returns Cloudinary upload result with secure URL
 */
export const uploadImage = async (
  filePath: string,
  folder: string,
  publicId?: string
): Promise<{ secure_url: string; public_id: string }> => {
  try {
    const options: any = {
      folder: `interest_book/${folder}`,
      resource_type: "auto", // auto-detect image, video, raw
      overwrite: false,
      invalidate: true,
    };

    if (publicId) {
      options.public_id = publicId;
    }

    const result = await cloudinary.uploader.upload(filePath, options);

    return {
      secure_url: result.secure_url,
      public_id: result.public_id,
    };
  } catch (error) {
    console.error("Cloudinary upload error:", error);
    throw new Error(`Failed to upload image to Cloudinary: ${error}`);
  }
};

/**
 * Upload image from buffer (for multipart/form-data)
 * @param buffer - File buffer
 * @param folder - Folder name in Cloudinary
 * @param fileName - Original file name
 * @returns Cloudinary upload result
 */
export const uploadImageFromBuffer = async (
  buffer: Buffer,
  folder: string,
  fileName: string
): Promise<{ secure_url: string; public_id: string }> => {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      {
        folder: `interest_book/${folder}`,
        resource_type: "auto",
        public_id: fileName.replace(/\.[^/.]+$/, ""), // Remove extension
      },
      (error, result) => {
        if (error) {
          reject(new Error(`Failed to upload image: ${error.message}`));
        } else if (result) {
          resolve({
            secure_url: result.secure_url,
            public_id: result.public_id,
          });
        } else {
          reject(new Error("Upload failed: No result returned"));
        }
      }
    );

    uploadStream.end(buffer);
  });
};

/**
 * Delete image from Cloudinary
 * @param publicId - Public ID of the image to delete
 */
export const deleteImage = async (publicId: string): Promise<void> => {
  try {
    await cloudinary.uploader.destroy(publicId);
  } catch (error) {
    console.error("Cloudinary delete error:", error);
    throw new Error(`Failed to delete image from Cloudinary: ${error}`);
  }
};

/**
 * Extract public ID from Cloudinary URL
 * @param url - Cloudinary URL
 * @returns Public ID or null
 */
export const extractPublicIdFromUrl = (url: string): string | null => {
  try {
    // Cloudinary URL format: https://res.cloudinary.com/{cloud_name}/image/upload/{folder}/{public_id}.{ext}
    const match = url.match(/\/upload\/.*\/(.+?)(\.[^.]+)?$/);
    if (match && match[1]) {
      // Remove folder path from public_id
      const fullPath = match[1];
      const parts = fullPath.split("/");
      return parts[parts.length - 1]; // Return the last part (actual public_id)
    }
    return null;
  } catch (error) {
    console.error("Error extracting public ID:", error);
    return null;
  }
};

export default cloudinary;

