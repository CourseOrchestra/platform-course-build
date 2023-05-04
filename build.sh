# repository rights???
[ ! -d "target" ] && mkdir target
./build-platform-module.sh

docker run --rm -v $PWD:/usr/src/app -w /usr/src/app node rm target/output -rf
docker run --rm -v $PWD:/usr/src/app -w /usr/src/app node mkdir target/output
docker run --rm -v $PWD:/usr/src/app -w /usr/src/app node chown node:node target/output


docker run --rm -v $PWD:/usr/src/app -w /usr/src/app node npm install
docker run -it --rm -v $PWD:/usr/src/app -w /usr/src/app node npx antora antora-playbook.yml

docker run --rm -v $PWD:/documents/ curs/asciidoctor-od ruby make-linkable.rb

cd target/
rm -rf platform-course-build
git clone -b gh-pages https://github.com/CourseOrchestra/platform-course-build.git
cd platform-course-build/
rm -rf */
cp -r ../output/*/ .
git add --all
git commit -m "force-push"
git push