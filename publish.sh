ohpm publish ./build/default/outputs/default/global.har

git add .

git commit -m "feat:发布$1版本"

git pull

git push

git tag "$1"

git push --tags