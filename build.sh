# repository rights???
[ ! -d "target" ] && mkdir target
docker run --rm -v $PWD:/documents/ curs/asciidoctor-od rm target/doc -rf
docker run --rm -v $PWD:/documents/ curs/asciidoctor-od mkdir target/doc
docker run --rm -v $PWD:/documents/ curs/asciidoctor-od mkdir target/doc/components

./build-platform-module.sh

docker run --rm -v $PWD:/usr/src/app -w /usr/src/app node rm target/output -rf
docker run --rm -v $PWD:/usr/src/app -w /usr/src/app node mkdir target/output
docker run --rm -v $PWD:/usr/src/app -w /usr/src/app node chown node:node target/output


docker run --rm -v $PWD:/usr/src/app -w /usr/src/app node npm install
docker run -it --rm -v $PWD:/usr/src/app -w /usr/src/app node npx antora antora-playbook.yml

docker run --rm -v $PWD:/documents/ curs/asciidoctor-od ruby make-linkable.rb
docker run --rm -v $PWD:/documents/ curs/asciidoctor-od ruby insert-syntrax.rb
