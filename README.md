# ChatterboxHost

Starting place to develop a drop-in "live customer support chat" Hex package. This would be an alternative to something like Zopim for Phoenix apps.

Features:

- Allow multiple support staff to take part in same conversation with a customer
- Save all messages in conversation in the database for later review (eg, to fix site issues that a lot of people struggled with)
- Conversations can be tagged arbitrarily, eg "bug" or "suggestion" or "reviewed"
- Support non-logged-in users

Anti-features:

- Won't support having customer service people watch people move around the site an initiate chats with them, because that's creepy.
