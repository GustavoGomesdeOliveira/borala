/**
 * Copyright 2016 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
// Configure the email transport using the default SMTP transport and a GMail account.
// For Gmail, enable these:
// 1. https://www.google.com/settings/security/lesssecureapps
// 2. https://accounts.google.com/DisplayUnlockCaptcha
// For other types of transports such as Sendgrid see https://nodemailer.com/transports/
// TODO: Configure the `gmail.email` and `gmail.password` Google Cloud environment variables.
const gmailEmail = encodeURIComponent(functions.config().gmail.email);
const gmailPassword = encodeURIComponent(functions.config().gmail.password);
const mailTransport = nodemailer.createTransport(
    `smtps://${gmailEmail}:${gmailPassword}@smtp.gmail.com`);
// Your company name to include in the emails
// TODO: Change this to your app or company name to customize the email sent.
const APP_NAME = 'We love eat';

admin.initializeApp(functions.config().firebase);

// [START send Report User Email]
/**
 * Sends a welcome email to new user.
 */
// [START onWriteTrigger]
exports.sendReportUserEmail = functions.database.ref('/reportedUsers/{dictionary}').onWrite(event => {
// [END onWriteTrigger]
  // [START eventAttributes]
  //const user = event.data; // The Firebase user.
  //const email = user.email; // The email of the user.
  //const displayName = user.displayName; // The display name of the user.
  const userId = event.data.key;
  // [END eventAttributes]

  return sendReportUserEmail(userId);
});
// [END send Report User Email]

// Sends a report email to the admin.
function sendReportUserEmail(userId) {
  const mailOptions = {
    from: `${APP_NAME} <noreply@firebase.com>`,
    to: "we.love.eat@outlook.com"
  };

  // The user subscribed to the newsletter.
  mailOptions.subject = `Report user to ${APP_NAME}!`;
  mailOptions.text = `Hey the user ${userId || ''} was reported. Please verify.`;
  return mailTransport.sendMail(mailOptions).then(() => {
    console.log('New report email sent to:');
  });
}

/**
 * Triggers when a user gets a new follower and sends a notification.
 *
 * Followers add a flag to `/followers/{followedUid}/{followerUid}`.
 * Users save their device notification tokens to `/users/{followedUid}/notificationTokens/{notificationToken}`.
 */
/**
 * Triggers when a user gets a new follower and sends a notification.
 *
 * Followers add a flag to `/followers/{followedUid}/{followerUid}`.
 * Users save their device notification tokens to `/users/{followedUid}/notificationTokens/{notificationToken}`.
 */
exports.sendMessageNotification = functions.database.ref('/chats/{chatsUid}').onWrite(event => {
  const chatUid = event.params.chatsUid;
  const senderId = event.data.val().senderId;
  const snapshot = event.data;

// Only send a notification when a new message has been created.
  //if ( snapshot.previous.val() ){
    //return console.log('same previous snapshot');
  //}

  // Notification details.
  const text = snapshot.val().text;
  const payload = {
    notification: {
      title: `New message from ${snapshot.val().senderName}`,
      body: text ? (text.length <= 100 ? text : text.substring(0, 97) + '...') : '',
      sound: 'default'
    }
  };
  
  function checkSenderID(id){ return id != snapshot.val().senderId}//filter array to drop senderId.
  
  // Get the list of participants Ids of chats.
  const chatsPromise = admin.database().ref('/chatsMembers/' + chatUid).once('value');

  return Promise.all( [chatsPromise] ).then( results => {
    var chatMembersId = Object.keys(results[0].val());
    chatMembersId = chatMembersId.filter(checkSenderID);
    var i;
    for (i = 0; i < chatMembersId.length; i++){
      console.log('chamou');

        const tokenPromise = admin.database().ref('/users/' + chatMembersId[i] + '/notificationToken').once('value');
        return Promise.all([tokenPromise]).then( result => {
          console.log(result[0].val());
          return admin.messaging().sendToDevice(result[0].val(), payload).then(response => {});
        });
    }

  });
});

/*exports.deleteOldEvents = functions.database.ref('/events/{EventsId}')
.onWrite( event => {
  var ref = event.data.ref.parent; // reference to the items
  var now = Date.now();
  var cutoff = now - 2 * 60 * 60 * 1000;
  var oldItemsQuery = ref.orderByChild('timestamp').endAt(cutoff);
  return oldItemsQuery.once('value', function(snapshot) {
    // create a map with all children that need to be removed
    var updates = {};
    snapshot.forEach(function(child) {
      updates[child.key] = null
    });
    // execute all updates in one go and return the result to end the function
    return ref.update(updates);
  });*/
//});