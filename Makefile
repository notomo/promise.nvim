test:
	vusted --shuffle
.PHONY: test

doc:
	rm -f ./doc/promise.nvim.txt
	nvim --headless -i NONE -n +"lua dofile('./spec/lua/promise/doc.lua')" +"quitall!"
	cat ./doc/promise.nvim.txt
.PHONY: doc
