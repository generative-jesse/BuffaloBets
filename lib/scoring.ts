export function calculateScore(
  predictedArtists: string[],
  predictedSongs: string[],
  actualArtists: string[],
  actualSongs: string[]
) {
  const correctArtists = predictedArtists.filter(a =>
    actualArtists.includes(a)
  ).length;

  const correctSongs = predictedSongs.filter(s =>
    actualSongs.includes(s)
  ).length;

  const totalCorrect = correctArtists + correctSongs;

  let rankingAccuracyScore = 0;

  predictedArtists.forEach((artist, predIdx) => {
    const actualIdx = actualArtists.indexOf(artist);
    if (actualIdx !== -1) {
      rankingAccuracyScore += Math.abs(predIdx - actualIdx);
    }
  });

  predictedSongs.forEach((song, predIdx) => {
    const actualIdx = actualSongs.indexOf(song);
    if (actualIdx !== -1) {
      rankingAccuracyScore += Math.abs(predIdx - actualIdx);
    }
  });

  let exactMatchScore = 0;

  predictedArtists.forEach((artist, idx) => {
    if (actualArtists[idx] === artist) {
      exactMatchScore += (5 - idx);
    }
  });

  predictedSongs.forEach((song, idx) => {
    if (actualSongs[idx] === song) {
      exactMatchScore += (5 - idx);
    }
  });

  return {
    correctArtists,
    correctSongs,
    totalCorrect,
    rankingAccuracyScore,
    exactMatchScore
  };
}

export function rankPlayers(scores: Array<{
  user_id: string;
  totalCorrect: number;
  rankingAccuracyScore: number;
  exactMatchScore: number;
}>) {
  return scores.sort((a, b) => {
    if (b.totalCorrect !== a.totalCorrect) {
      return b.totalCorrect - a.totalCorrect;
    }
    if (a.rankingAccuracyScore !== b.rankingAccuracyScore) {
      return a.rankingAccuracyScore - b.rankingAccuracyScore;
    }
    return b.exactMatchScore - a.exactMatchScore;
  });
}

export function calculateBuffaloBalances(rankedPlayerIds: string[]) {
  const balances: Array<{ caller_id: string; recipient_id: string; balance: number }> = [];

  if (rankedPlayerIds.length >= 4) {
    balances.push({ caller_id: rankedPlayerIds[0], recipient_id: rankedPlayerIds[1], balance: 1 });
    balances.push({ caller_id: rankedPlayerIds[0], recipient_id: rankedPlayerIds[2], balance: 2 });
    balances.push({ caller_id: rankedPlayerIds[0], recipient_id: rankedPlayerIds[3], balance: 3 });

    balances.push({ caller_id: rankedPlayerIds[1], recipient_id: rankedPlayerIds[2], balance: 1 });
    balances.push({ caller_id: rankedPlayerIds[1], recipient_id: rankedPlayerIds[3], balance: 2 });

    balances.push({ caller_id: rankedPlayerIds[2], recipient_id: rankedPlayerIds[3], balance: 1 });
  }

  return balances;
}
