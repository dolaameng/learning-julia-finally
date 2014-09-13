using Morsel
using JSON
include("word2vec.jl")

app = Morsel.app()

route(app, GET, "/") do req, res
	readall(open("index.html"))
end

route(app, GET, "data.json") do req, res
	#readall(open("data.json"))
	q = urlparam(req, :q)
	q = q == nothing ? "" : q
	q = lowercase(strip(q))
	#q = "albert einstein"
	r = word2vec_tree(q, 20, 2)
	json(r)
end

route(app, GET, "d3.v3.min.js") do req, res
	readall(open("d3.v3.min.js"))
end

route(app, GET, "jquery-2.1.1.min.js") do req, res
	readall(open("jquery-2.1.1.min.js"))
end

route(app, GET, "test") do req, res
	json(urlparam(req, :q))
end

start(app, 8000)