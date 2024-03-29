echo "Build platform module"
docker run --rm -v $PWD:/documents/ curs/asciidoctor-od rm target/platform-course-build -rf
docker run --rm -v $PWD:/documents/ curs/asciidoctor-od cp platform-course-build target -r
docker run --rm -v $PWD:/documents/ curs/asciidoctor-od mkdir target/platform-course-build/modules/ROOT/partials

docker run --rm -v $PWD/..:/documents/ -w /documents/platform-course-build curs/asciidoctor-od cp ../st2-ui target/platform-course-build/modules/ROOT/partials -r
docker run --rm -v $PWD/..:/documents/ -w /documents/platform-course-build curs/asciidoctor-od cp ../st2-api target/platform-course-build/modules/ROOT/partials -r
docker run --rm -v $PWD/..:/documents/ -w /documents/platform-course-build curs/asciidoctor-od cp ../qt2-api target/platform-course-build/modules/ROOT/partials -r
docker run --rm -v $PWD/..:/documents/ -w /documents/platform-course-build curs/asciidoctor-od cp ../showcase3-demo target/platform-course-build/modules/ROOT/partials -r
docker run --rm -v $PWD:/documents/ curs/asciidoctor-od cp target/platform-course-build/modules/ROOT/nav.adoc target/platform-course-build/modules/ROOT/partials/nav-copy.adoc
