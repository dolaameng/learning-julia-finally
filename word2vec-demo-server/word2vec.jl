@everywhere WORD2VEC_PATH = "../word2vec/"
@everywhere DIST_COMMAND = joinpath(WORD2VEC_PATH, "distance_command")
@everywhere BIN_FILE = joinpath(WORD2VEC_PATH, "share-phrase.bin")
#@everywhere BIN_FILE = joinpath(WORD2VEC_PATH, "vectors-phrase.bin")

@everywhere function word2vec_query(q, n = 40)
    cmd = `$DIST_COMMAND $BIN_FILE $q`
    result = readchomp(cmd)
    pattern = r"\w+\t\t[\d.]+"
    word_wts = map(str -> split(str, "\t\t"), matchall(pattern, result))
    word_wts = map(pair -> (replace(pair[1], "_", " "), float(pair[2])), word_wts)
    words = map(p -> p[1], word_wts)
    if length(words) >= n
        return words[1:n]
    else
        return words
    end
end

@everywhere function word2vec_tree(q, n = 20, d = 2)
    """
    n: number of nodes per level
    d: depth of levels
    """
    if d == 1
        tree = {:name => q, 
            :children => [{:name => qq} for qq in word2vec_query(q, n)]}
    else
        tree = {:name => q, 
                :children => [word2vec_tree(qq, n, d-1) 
                for qq in word2vec_query(q, n)]}
    end
    tree
end

@everywhere function word2vec_tree_parallel(q, n = 10, d = 4)
    """
    n: number of nodes per level
    d: depth of levels
    """
    if d == 1
        tree = {:name => q, 
            :children => [{:name => qq} for qq in word2vec_query(q, n)]}
    else
        children = @parallel vcat for qq in word2vec_query(q, n)
            word2vec_tree(qq, n, d-1)
        end
        tree = {:name => q, 
            :children => children}
    end
    tree
end