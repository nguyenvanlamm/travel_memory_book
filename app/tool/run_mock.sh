#!/usr/bin/env bash
# Chạy app local trên web với thư viện demo (6 cuốn trong design-demos/spec.md)
# thay vì thư viện trống. Dữ liệu chỉ nằm trong bộ nhớ, tải lại trang là nạp lại.
#
#   app/tool/run_mock.sh                 # http://localhost:8080
#   PORT=9000 app/tool/run_mock.sh
#   DEVICE=chrome app/tool/run_mock.sh   # mở Chrome, có hot reload
#
# Ảnh demo (Wikimedia, CC BY-SA — xem design-demos/assets/CREDITS.md) chỉ được
# chép tạm vào web/mock-photos trong lúc chạy và xoá khi thoát, để không lọt vào
# build/web (bản Netlify) hay bản build phát hành.
set -euo pipefail
cd "$(dirname "$0")/.."

rm -rf web/mock-photos
cp -r ../design-demos/assets/photos web/mock-photos
trap 'rm -rf web/mock-photos' EXIT

flutter run -d "${DEVICE:-web-server}" \
  --web-port "${PORT:-8080}" --web-hostname localhost \
  --dart-define=MOCK_DATA=true "$@"
