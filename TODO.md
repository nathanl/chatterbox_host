- Stop setting up chat box on every page. Instead, pages that want it should include a partial; if the JS sees the appropriate div, it will set it up.
- The CS chat panel will not include that partial
- In callback:
  - Prompt user for name if not logged in (initially just use "Anonymous")
  - Set up chat window, using given chat room name and username

## Ideas for Later
- Support file uploads?
- Give conversation tags fields for "background-color" and "text-color" so that CS reps can create and style tags, like on Github issues
- Support callbacks: when a user starts a conversation, when one is tagged or untagged, when one is closed, ... ? This would allow people to add lots of features without supporting them directly (eg, "email me when", Growl notifications, "blink a light in the office when", record info for later reporting, etc)
- Add a way for CS reps to chat with each other: "do you know X?" or "can you join us in conversation 123?"
- CS reps will keep each chat in its own browser tab. Put helpful info/indicators in the `<title>` of each tab. Ideas: user name, exclamation point or some emoji if any unread messages...

# Name ideas, if packagified

- "Help" related
  - Boost*
  - Support
  - Abet
- "Chat" related
  - Gab*
  - Blab
  - Yak
  - Consult
  - Confer
  - Parley*
  - Charlar or Platicar
  - Confabulate!!

# Notes on Zopim:
- Asks for name, email and topic at start of chat
- Messages appear in little speech bubbles from self and agent, self on right, agent on left. Speaker name is bolded at top of bubble, and speaker profile image is where speech bubble appears to come from.
- Basic integration is just "add this JS snippet to your page"
- Ties chat to a session
- If reload the page, all messages from conversation repopulate
- Can open chat in a separate tab and also use widget. The two are synced.
- Can attach files to the chat
- Can rate the chat
- Can get a transcript emailed to self
- Agents can come and go from the chat
- There's an "End this Chat" button - presumably if I did that, and opened the chat window again, it would be a new conversation?
