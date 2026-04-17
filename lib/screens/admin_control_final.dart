// यह कोड यूजर लिस्ट की ListTile के अंदर लगेगा
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: Icon(Icons.edit, color: Colors.blue),
      onPressed: () { /* पद और नाम एडिट करने का पेज */ },
    ),
    IconButton(
      icon: Icon(Icons.block, color: Colors.red),
      onPressed: () {
        // यहाँ से यूजर का 'status' 'blocked' कर देंगे
        // जिससे ऐप खुलते ही उसे "You are blocked" मैसेज दिखेगा
      },
    ),
  ],
),
