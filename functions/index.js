// functions/index.js
const admin = require("firebase-admin");
const axios = require("axios");
const functions = require("firebase-functions");

// v2 storage trigger import
const {onObjectFinalized} = require("firebase-functions/v2/storage");

exports.onSosRecordingUpload = onObjectFinalized(
    {
    // use the bucket name you saw in Cloud Console
      bucket: "needu-86b9a.firebasestorage.app",
      region: "us-central1",
    },
    async (event) => {
    //   const object = event.data;
      admin.initializeApp();
      functions.config() || {};

      const TEXTBELT_KEY = functions.config().textbelt.key;

      // Trigger: runs when an object is finalized (upload complete)
      exports.onSosRecordingUpload = onObjectFinalized(async (event) => {
        try {
          // In v2 the payload object is under event.data
          const object = event.data;
          if (!object || !object.name) {
            console.log("No object or name in event.");
            return null;
          }

          const objectName = object.name;
          console.log("Uploaded object:", objectName);

          const parts = objectName.split("/");
          // ["sos_recordings", "{uid}", "Triggered_on_{date}", "{filename}"]
          if (
            parts.length < 4 ||
      parts[0] !== "sos_recordings" ||
      !parts[2].startsWith("Triggered_on_")
          ) {
            console.log(
                "Object path doesn't match expected " +
          "sos_recordings/{uid}/Triggered_on_{date}/... pattern.",
            );
            return null;
          }

          const uid = parts[1];
          const dateFolder = parts[2].replace("Triggered_on_", "");
          const prefix = `sos_recordings/${uid}/Triggered_on_${dateFolder}/`;

          console.log("UID:", uid, "dateFolder:", dateFolder);

          // bucket may be present on object; otherwise use default
          const bucketName = object.bucket || admin.storage().bucket().name;
          const bucket = admin.storage().bucket(bucketName);

          // list files under the prefix
          const [files] = await bucket.getFiles({prefix});
          if (!files || files.length === 0) {
            console.log("No files found in prefix:", prefix);
            return null;
          }

          // get metadata for each file
          const filesWithMeta = await Promise.all(
              files.map(async (f) => {
                const [metadata] = await f.getMetadata();
                return {file: f, metadata};
              }),
          );

          // sort by timeCreated descending (newest first)
          filesWithMeta.sort((a, b) => {
            const tA = new Date(a.metadata.timeCreated).getTime();
            const tB = new Date(b.metadata.timeCreated).getTime();
            return tB - tA;
          });

          const newest = filesWithMeta[0];
          const newestPath = newest.file.name;
          console.log("Newest file (by timeCreated):", newestPath);

          // skip if uploaded object isn't the newest
          if (objectName !== newestPath) {
            console.log("Uploaded file is not newest. Skipping notification.");
            return null;
          }

          // create signed url valid 24 hours
          const expiresAt = Date.now() + 24 * 60 * 60 * 1000;
          const [signedUrl] = await newest.file.getSignedUrl({
            action: "read",
            expires: new Date(expiresAt),
          });

          console.log("Signed URL created.");

          // fetch user doc and emergency contacts
          const userDocRef = admin.firestore().collection("users").doc(uid);
          const userSnap = await userDocRef.get();
          if (!userSnap.exists) {
            console.log("User doc not found for uid:", uid);
            return null;
          }

          const userData = userSnap.data() || {};
          const senderPhone = userData.phoneNumber || uid;
          let emergencyContacts = userData.emergencyContacts || [];

          // normalize to array
          if (!Array.isArray(emergencyContacts)) {
            emergencyContacts = Object.values(emergencyContacts || {});
          }

          if (!emergencyContacts || emergencyContacts.length === 0) {
            console.log("No emergency contacts to notify for uid:", uid);
            return null;
          }

          // send SMS via Textbelt
          const results = [];
          for (const contact of emergencyContacts) {
            const phone =
        typeof contact === "string" ?
          contact :
          contact.phone || contact.number || contact.mobile;
            if (!phone) {
              console.log("Skipping contact without phone:", contact);
              continue;
            }

            const message=`SOS audio from ${senderPhone}. Listen:${signedUrl}`;

            const payload = {
              phone,
              message,
              key: TEXTBELT_KEY,
            };

            const config = {
              headers: {"Content-Type": "application/json"},
              timeout: 15000,
            };

            try {
              const resp = await axios.post(
                  "https://textbelt.com/text",
                  payload,
                  config,
              );
              console.log("Textbelt response for", phone, ":", resp.data);
              results.push({phone, ok: resp.data.success, data: resp.data});
            } catch (err) {
              const errMsg =
          err && err.response ? err.response.data || err.message : err.message;
              console.error("Failed to send SMS to", phone, ":", errMsg);
              results.push({phone, ok: false, error: errMsg});
            }
          }

          console.log("SMS send results:", results);
          return {success: true, results};
        } catch (error) {
          console.error("Error in onSosRecordingUpload:", error);
          return null;
        }
      });
    },
);

