enum PhotoVerdict {
  likelyGenuine,
  possiblyEdited,
  likelyAiGenerated,
  inconclusive;

  String get label => switch (this) {
        PhotoVerdict.likelyGenuine => 'Likely genuine',
        PhotoVerdict.possiblyEdited => 'Possibly edited',
        PhotoVerdict.likelyAiGenerated => 'Likely AI-generated',
        PhotoVerdict.inconclusive => 'Inconclusive',
      };
}
