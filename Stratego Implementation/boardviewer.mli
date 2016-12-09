(*This is the interface used to view the current board*)
module type BoardViewer = sig
    (* [display_board b] displays the board in some manner. For example, 
     * this can print out a command-line representation of the board or 
     * it can draw a GUI representation of the given board state *)
    val display_board : board -> unit
end
