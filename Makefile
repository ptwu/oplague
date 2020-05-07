MODULES=src/country src/main src/virus src/world src/engine src/upgrades src/stats src/command src/converter src/server
OBJECTS=$(MODULES:=.cmo)
TEST=test.byte
MAIN=main.byte
SERVER=server.byte
OCAMLBUILD=ocamlbuild -use-ocamlfind

default: build
	utop

build:
	$(OCAMLBUILD) $(OBJECTS)

buildall:
	cd webapp; npm install
	$(OCAMLBUILD) $(OBJECTS)

test:
	$(OCAMLBUILD) src/$(TEST) && ./$(TEST) -runner sequential

run:
	$(OCAMLBUILD) src/$(MAIN)
	$(OCAMLBUILD) src/$(SERVER) && ./$(SERVER)& cd webapp; npm start

play:
	$(OCAMLBUILD) src/$(MAIN) && ./$(MAIN)

server:
	$(OCAMLBUILD) src/$(SERVER) && ./$(SERVER)
	
docs: build
	mkdir -p docs
	ocamlfind ocamldoc -I _build -package yojson,ANSITerminal,opium \
		-html -stars -d docs src/*.ml[i]

clean:
	ocamlbuild -clean
	rm -rf docs
	
zip:
	ocamlbuild -clean && zip -r outbreak.zip * .merlin .ocamlinit .gitignore -x webapp/node_modules/\*