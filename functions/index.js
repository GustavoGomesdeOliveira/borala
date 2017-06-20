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
admin.initializeApp(functions.config().firebase);

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
  console.log('We have a new message');
  console.log('chat..',chatUid);
  console.log('senderId', senderId);

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
        const tokenPromise = admin.database().ref('/users/' + chatMembersId[i] + '/notificationToken').once('value');
        return Promise.all([tokenPromise]).then( result => {
          console.log('token ', result[0].val());
          return admin.messaging().sendToDevice(result[0].val(), payload).then(response => {});
        });
    }

  });
});