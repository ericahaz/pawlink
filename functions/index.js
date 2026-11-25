
const { setGlobalOptions } = require("firebase-functions");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

const { initializeApp } = require("firebase-admin/app");
const {
  getFirestore,
  FieldValue,
} = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

setGlobalOptions({
  maxInstances: 10,
});

/**
 * Creates in-app notifications and sends push notifications
 * whenever a guest submits a found-pet report through a pet QR page.
 *
 * Trigger:
 * found_reports/{reportId}
 */
exports.notifyPetOwnersOfFoundReport = onDocumentCreated(
  "found_reports/{reportId}",
  async (event) => {
    const report = event.data?.data();
    const reportId = event.params.reportId;

    if (!report) {
      console.log("No report data found:", reportId);
      return;
    }

    const petId =
      typeof report.petId === "string" ? report.petId.trim() : "";

    if (!petId) {
      console.log("Report has no registered pet ID:", reportId);
      return;
    }

    try {
      // Find the registered pet.
      const petSnapshot = await db.collection("pets").doc(petId).get();

      if (!petSnapshot.exists) {
        console.log("Pet not found:", petId);
        return;
      }

      const pet = petSnapshot.data();

      // Do not notify owners if the pet's QR profile is disabled.
      if (pet.qrEnabled !== true) {
        console.log("Pet QR is disabled:", petId);
        return;
      }

      // Collect all owners and remove duplicate UIDs.
      const ownerIds = new Set();

      if (Array.isArray(pet.ownerIds)) {
        for (const ownerId of pet.ownerIds) {
          if (typeof ownerId === "string" && ownerId.trim()) {
            ownerIds.add(ownerId.trim());
          }
        }
      }

      if (
        typeof pet.primaryOwnerId === "string" &&
        pet.primaryOwnerId.trim()
      ) {
        ownerIds.add(pet.primaryOwnerId.trim());
      }

      if (ownerIds.size === 0) {
        console.log("No owners found for pet:", petId);
        return;
      }

      const petName =
        typeof pet.petName === "string" && pet.petName.trim()
          ? pet.petName.trim()
          : "your pet";

      const location =
        typeof report.location === "string" && report.location.trim()
          ? report.location.trim()
          : "an unspecified location";

      const reportMessage =
        typeof report.message === "string" ? report.message : "";

      const title = `${petName} may have been found!`;
      const body = `Someone reported finding ${petName} at ${location}.`;

      // Process each owner separately.
      for (const ownerId of ownerIds) {
        const notificationId = `${reportId}_${ownerId}`;

        const notificationRef = db
          .collection("notifications")
          .doc(notificationId);

        // Prevent duplicate in-app notifications if the event is retried.
        const wasCreated = await db.runTransaction(async (transaction) => {
          const existing = await transaction.get(notificationRef);

          if (existing.exists) {
            return false;
          }

          transaction.create(notificationRef, {
            userId: ownerId,
            type: "found_pet_report",
            title,
            body,
            petId,
            petName,
            reportId,
            location,
            message: reportMessage,
            isRead: false,
            createdAt: FieldValue.serverTimestamp(),
          });

          return true;
        });

        if (!wasCreated) {
          console.log("Notification already exists:", notificationId);
          continue;
        }

        console.log("In-app notification created for owner:", ownerId);

        // Find the owner's registered FCM devices.
        const devicesSnapshot = await db
          .collection("users")
          .doc(ownerId)
          .collection("fcmTokens")
          .get();

        if (devicesSnapshot.empty) {
          console.log("No registered push devices for owner:", ownerId);
          continue;
        }

        // Send a push notification to each registered device.
        for (const deviceDoc of devicesSnapshot.docs) {
          const deviceData = deviceDoc.data();

          const token =
            typeof deviceData.token === "string"
              ? deviceData.token.trim()
              : "";

          if (!token) {
            console.log("Device has no FCM token:", deviceDoc.id);
            continue;
          }

          try {
            const messageId = await messaging.send({
              token,
              notification: {
                title,
                body,
              },
              data: {
                type: "found_pet_report",
                notificationId,
                petId,
                petName,
                reportId,
                location,
              },
            });

            console.log(
              "Push notification sent:",
              messageId,
              "Owner:",
              ownerId
            );
          } catch (pushError) {
            console.error(
              "Could not send push notification to device:",
              deviceDoc.id,
              pushError
            );

            const errorCode = pushError.code || "";

            // Remove invalid FCM registration tokens.
            if (
              errorCode ===
                "messaging/registration-token-not-registered" ||
              errorCode === "messaging/invalid-registration-token"
            ) {
              await deviceDoc.ref.delete().catch((deleteError) => {
                console.error(
                  "Could not remove invalid FCM token:",
                  deleteError
                );
              });
            }
          }
        }
      }

      console.log(
        "Found-pet notification processing completed:",
        reportId
      );
    } catch (error) {
      console.error(
        "Error processing found-pet report:",
        reportId,
        error
      );

      throw error;
    }
  }
);
