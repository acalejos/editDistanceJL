using Luxor

# From https://en.wikipedia.org/wiki/Wagner%E2%80%93Fischer_algorithm
function DistanceMatrix(s::String, t::String)
    s = lowercase(s)
    t = lowercase(t)
    m = length(s)
    n = length(t)
    # for all i and j, d[i,j] will hold the Levenshtein distance between
    # the first i characters of s and the first j characters of t
    # note that d has (m+1)*(n+1) values
    d = zeros(m + 1, n + 1)
   
    #set each element in d to zero
   
    # source prefixes can be transformed into empty string by
    # dropping all characters
    for i = 0:m
        d[i + 1, 1] = i
    end
   
    # target prefixes can be reached from empty source prefix
    # by inserting every character
    for j = 0:n
        d[1, j + 1] = j
    end
   
    for j = 2:n + 1
        for i = 2:m + 1
            if s[i - 1] == t[j - 1]
                substitutionCost = 0
            else
                substitutionCost = 1
            end
            
            #=
            d[i, j] := minimum(d[i-1, j] + 1,                   // deletion -> 0
                               d[i, j-1] + 1,                   // insertion -> 1
                               d[i-1, j-1] + substitutionCost)  // substitution -> 2
            =#
            d[i,j] = min(d[i - 1, j] + 1, d[i, j - 1] + 1, d[i - 1, j - 1] + substitutionCost)
        end
    end
    return d
end

function LevenshteinDistance(s::String, t::String)
    return DistanceMatrix(s, t)[length(s) + 1,length(t) + 1]
end

function bestDir(d, i, j)
    best = min(d[i - 1, j], d[i, j - 1], d[i - 1, j - 1])
    if (best == d[i - 1, j])
        di = -1
        dj = 0
    elseif (best == d[i, j - 1])
        di = 0
        dj = -1
    else
        di = -1
        dj = -1
    end
    return di, dj
end

function editPath(s::String, t::String, verbose = false)
    d = DistanceMatrix(s, t)
    working = collect(s)
    m, n = size(d)
    i = m
    j = n
    path = []
    tiles = []
    append!(tiles, [(i,j)])
    while(!(i == 1 && j == 1))
        
        di, dj = bestDir(d, i, j)
        if (di == -1 && dj == -1)
            if (s[i - 1] != t[j - 1])
                # Substitution
                if (verbose)
                    println("Substitution of $(s[i - 1]) for $(t[j - 1])")
                end
                working[(i - 1)] = t[j - 1]
            end
        elseif (di == -1)
            # Deletion
            if (verbose)
                println("Delete $(s[i - 1])")
            end
            splice!(working, (i - 1))
        else
            # Insertion
            if (verbose)
                println("Insertion of $(t[j - 1])")
            end
            insert!(working, (i + 1), t[j - 1])
        end
        i += di
        j += dj
        append!(path, [copy(working)])
        append!(tiles, [(i,j)])
    end
    return path, tiles
end

function visualize(s::String, t::String)
    d = DistanceMatrix(s, t)
    #d = transpose(d)
    path, route = editPath(s, t)
    #t = Table(size(d))
    s1, s2 = size(d)
    tiles = Tiler(500, 500, size(d)[1] + 1, size(d)[2] + 1, margin = 20)
    println(route)
    @png begin
        fontsize(24)
        println(size(d))
        for (pos, n) in tiles
            i = tiles.currentrow
            j = tiles.currentcol
            w = tiles.tilewidth
            h = tiles.tileheight
        # pos is the center of the tile
            println(n)
            println("$i , $j")
            if (i == 1 && j ==1)
                sethue("black")
                box(pos, w, h, :stroke)
            elseif (i == 1)
                sethue("black")
                box(pos, w, h, :stroke)
                text(string(t[j - 1]), pos)
            elseif (j == 1)
                sethue("black")
                box(pos, w, h, :stroke)
                text(string(s[Int(round(n / s1))]), pos)
            elseif ((i,j) in route)
                sethue("blue")
                box(pos, w, h, :stroke)
                text(string(d[i - 1,j - 1]), pos)
            else
                sethue("black")
                box(pos, w, h, :stroke)
                text(string(d[i - 1,j - 1]), pos)
            end
        end
    end
end