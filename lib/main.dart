// वीडियो लिस्ट के लिए मुख्य विजेट का लॉजिक
ListView.builder(
  itemCount: videoLinks.length,
  itemBuilder: (context, index) {
    return Column(
      children: [
        VideoPlayerWidget(url: videoLinks[index], isMuted: true),
        Text("डोनर: ${donorNames[index]} ने ₹${amount[index]} दान किए"), // टिकर/चलता हुआ नाम
      ],
    );
  },
)
