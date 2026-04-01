#!/bin/bash
# watch-and-pull.sh — Mac 端自動追蹤 main 並 pull

#flutter run -d all
#./watch-and-pull.sh
BRANCH="main"
INTERVAL=10  # 幾秒檢查一次，可以改

echo "開始監控 origin/$BRANCH（每 ${INTERVAL} 秒檢查一次）"
echo "按 Ctrl+C 停止"

while true; do
  git fetch origin "$BRANCH" --quiet

  LOCAL=$(git rev-parse "$BRANCH")
  REMOTE=$(git rev-parse "origin/$BRANCH")

  if [ "$LOCAL" != "$REMOTE" ]; then
    echo ""
    echo "$(date): 偵測到新 commit，pulling..."
    git pull origin "$BRANCH"
    echo "$(date): 完成！flutter run 會自動 hot reload"
    echo ""
  fi

  sleep "$INTERVAL"
done
