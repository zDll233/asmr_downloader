bool isSourceIdValid(String sourceId) =>
    RegExp(r'^(RJ|VJ|BJ)?\d+$', caseSensitive: false).hasMatch(sourceId);
