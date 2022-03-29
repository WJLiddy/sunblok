require 'colorize'
require_relative 'pieces'
require_relative 'game'

# interface this later
require_relative '../ai_rand/run'
require_relative '../ai_greedy/run'
require_relative '../ai_minimax/run'

# render lists of white and black pieces
def render(pieces_white,pieces_black)
    white = list_to_coords(pieces_white)
    black = list_to_coords(pieces_black)
    (-1..14).each do |y|
        (-1..14).each do |x|
            if (white.include? [x,y])
                print "■ ".white 
            elsif (black.include? [x,y])
                print "■ ".black 
            else
                (x != -1 && x != 14 && y != -1 && y != 14) ? (print "■ ".blue) : (print "■ ".red)
            end
        end
        puts
    end
end

def score(piece_names)
    piece_names.map{|p| get_piece_list()[p].length}.sum
end

def play_game(white_ai, black_ai, render_game, clear_render)
    # auto place first tile (for test)
    white_pieces_left = get_piece_list.keys
    black_pieces_left = get_piece_list.keys

    white_pieces_placed = []
    black_pieces_placed = []

    # generate game states
    white_turn = true
    white_yield = false
    black_yield = false

    # game loop
    while(true)
        # skip turn if yield.
        if (white_turn && white_yield)
            white_turn = !white_turn
            break if (white_yield and black_yield)
            next
        end

        if ((!white_turn) && black_yield)
            white_turn = !white_turn
            break if (white_yield and black_yield)
            next
        end

        return [score(white_pieces_left),score(black_pieces_left)] if (white_pieces_left == [] or black_pieces_left == [])
        

        # collect the move.
        if(white_turn)
            move = white_ai.run(white_pieces_placed, black_pieces_placed)
        else
            move = black_ai.run(black_pieces_placed,white_pieces_placed)
        end

        # if the move was nil, they yielded.
        if(move == nil)
            if (white_turn)
                white_yield = true 
                puts "White has yielded. Skip turn." if render_game
                puts if render_game
            else
                black_yield = true 
                puts "Black has yielded. Skip turn." if render_game
                puts if render_game
            end
            white_turn = !white_turn
            next
        end

        if legal(move,white_pieces_placed,black_pieces_placed,white_turn)
            if(white_turn)
                white_pieces_placed.append(move)
                white_pieces_left.delete(move["name"])
            else
                black_pieces_placed.append(move)
                black_pieces_left.delete(move["name"])
            end
        else
            # invalid move, so yield.
            puts "Illegal move posted by " + (white_turn ? "White" : "Black")
            if (white_turn)
                white_yield = true 
                puts "White has yielded. Skip turn." if render_game
                puts if render_game
            else
                black_yield = true 
                puts "Black has yielded. Skip turn." if render_game
                puts if render_game
            end
            white_turn = !white_turn
            next
        end

        if(render_game)
            # Render does no error checking, beware
            system "clear" if clear_render
            render(white_pieces_placed,black_pieces_placed)
            puts(((!white_turn) ? "White" : "Black") + " to move.")
            puts("White pieces left:\n" + white_pieces_left.to_s + " (" + score(white_pieces_left).to_s + ")") 
            puts("Black pieces left:\n" + black_pieces_left.to_s + " (" + score(black_pieces_left).to_s + ")" )
            puts
            sleep(0.5)
        end
        white_turn = !white_turn
    end
    return [score(white_pieces_left),score(black_pieces_left)]
end



res = play_game(MiniMax.new(3),MiniMax.new(3), true, true)


=begin
AIs = [
["SMALL_FIRST",Greedy.new(false)],
["LARGE_FIRST",Greedy.new(true)],
["MINIMAX_3",MiniMax.new(3)],
["MINIMAX_4",MiniMax.new(4)],
["RANDOM",Rand.new()],
]

AIs.permutation(2).each do |a|
    record = [0,0,0]
    25.times do 
        res = play_game(a[0][1],a[1][1], false, false)
        record[0] += 1 if res[0] < res[1]
        record[1] += 1 if res[0] == res[1]
        record[2] += 1 if res[0] > res[1]
    end
    25.times do 
        res = play_game(a[1][1],a[0][1], false, false)
        record[2] += 1 if res[0] < res[1]
        record[1] += 1 if res[0] == res[1]
        record[0] += 1 if res[0] > res[1]
    end
    puts a[0][0] + " vs " + a[1][0]
    puts record
end
=end