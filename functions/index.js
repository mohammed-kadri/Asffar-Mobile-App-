


const { onRequest } = require("firebase-functions");
const logger = require("firebase-functions/logger");
const functions = require('firebase-functions');
//import {getFirestore} from "firebase-admin/firestore";

//import {initializeApp} from "firebase-admin/app";
const admin = require('firebase-admin');



admin.initializeApp();
 




//y
//exports.deletePostImages = functions.firestore.("trips/{postId}", async (snap, context) => {
//    // Get an object representing the document
//    // e.g. {'name': 'Marie', 'age': 66}
//        const postId = context.params.postId;
//        const bucket = admin.storage().bucket();
//
//        // Reference to the folder containing the images
//        const folderRef = bucket.file(`posts/${postId}/`);
//
//        try {
//            // List all files in the folder
//            const [files] = await bucket.getFiles({ prefix: `posts/${postId}/` });
//
//            // Delete each file in the folder
//            const deletePromises = files.map(file => file.delete());
//            await Promise.all(deletePromises);
//
//            console.log(`Successfully deleted folder: posts/${postId}/`);
//        } catch (error) {
//            console.error(`Failed to delete folder: posts/${postId}/`, error);
//        }
//
//    // perform more operations ...
//});



exports.verifyAgencyAccount = functions.https.onRequest(async (req, res) => {
    const agencyId = req.query.agencyId;

    if (!agencyId) {
        return res.status(400).send('Agency ID is required');
    }

    try {
        const agencyDoc = await admin.firestore().collection('agencies').doc(agencyId).get();

        if (!agencyDoc.exists) {
            return res.status(404).send('Agency not found');
        }

        const agencyData = agencyDoc.data();
        const { submittedDocuments, documentsAccepted, emailVerified, profilePictureUrl } = agencyData;

        if (submittedDocuments && documentsAccepted && emailVerified && profilePictureUrl) {
            await admin.firestore().collection('agencies').doc(agencyId).update({
                accountVerified: true
            });
            return res.status(200).send('Account verified successfully');
        } else {
            return res.status(400).send('Conditions not met for account verification');
        }
    } catch (error) {
        console.error('Error verifying account:', error);
        return res.status(500).send('Internal Server Error');
    }
});


exports.getSubscriptionPrices = functions.https.onRequest(async (req, res) => {
    try {
        const subscriptionIds = ['1', '3', '12'];
        const pricesMap = {};

        for (const id of subscriptionIds) {
            const doc = await admin.firestore().collection('subscriptions_details').doc(id).get();
            if (doc.exists) {
                pricesMap[id] = doc.data().prices;
            } else {
                pricesMap[id] = null;
            }
        }

        return res.status(200).json(pricesMap);
    } catch (error) {
        console.error('Error fetching subscription prices:', error);
        return res.status(500).json(null);
    }
});



exports.checkPaymentVerification = functions.https.onRequest(async (req, res) => {
    const userId = req.query.userId;

    if (!userId) {
        return res.status(400).send('User ID is required');
    }

    try {
        const doc = await admin.firestore().collection('payment_verification').doc(userId).get();

        if (doc.exists) {
            return res.status(200).json({
                exists: true,
                data: doc.data()
            });
        } else {
            return res.status(200).json({
                exists: false,
                data: null
            });
        }
    } catch (error) {
        console.error('Error checking payment verification:', error);
        return res.status(500).send('Internal Server Error');
    }
});


exports.checkSubscription = functions.https.onRequest(async (req, res) => {
    const userId = req.query.userId;

    if (!userId) {
        return res.status(400).send('User ID is required');
    }

    try {
        const doc = await admin.firestore().collection('subscriptions').doc(userId).get();

        if (doc.exists) {
            return res.status(200).json({
                data: doc.data()
            });
        } else {
            return res.status(200).json({
                data: null
            });
        }
    } catch (error) {
        console.error('Error checking subscription:', error);
        return res.status(500).send('Internal Server Error');
    }
});


//exports.archivePaymentVerification = functions.firestore
//    .document('payment_verification/{docId}')
//    .onDelete(async (snap, context) => {
//        try {
//            const deletedData = snap.data();
//            const docId = context.params.docId;
//
//            // Add timestamp to the archived data
//            const dataToArchive = {
//                ...deletedData,
//                archivedAt: admin.firestore.FieldValue.serverTimestamp(),
//                originalId: docId,
//                deletedAt: new Date().toISOString()
//            };
//
//            // Save to archive collection
//            await admin.firestore()
//                .collection('payment_verification_archive')
//                .doc(docId)
//                .set(dataToArchive);
//
//            console.log(`Payment verification ${docId} archived successfully`);
//            return null; // Correct return for background functions
//        } catch (error) {
//            console.error('Error archiving payment verification:', error);
//            return null; // Correct return for background functions
//        }
//    });

//exports.deletePostImages = functions.firestore.document('posts/{postId}')
//    .onDelete(async (snap, context) => {
//        const postId = context.params.postId;
//        const bucket = admin.storage().bucket();
//
//        // Reference to the folder containing the images
//        const folderRef = bucket.file(`posts/${postId}/`);
//
//        try {
//            // List all files in the folder
//            const [files] = await bucket.getFiles({ prefix: `posts/${postId}/` });
//
//            // Delete each file in the folder
//            const deletePromises = files.map(file => file.delete());
//            await Promise.all(deletePromises);
//
//            console.log(`Successfully deleted folder: posts/${postId}/`);
//        } catch (error) {
//            console.error(`Failed to delete folder: posts/${postId}/`, error);
//        }
//    });